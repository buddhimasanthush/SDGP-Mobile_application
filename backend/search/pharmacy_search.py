"""
pharmacy_search.py — Pharmacy search algorithm for MediFind.

Works with the actual Supabase schema:
  - pharmacies: id (int), name (text), latitude (float), longitude (float)
  - inventory:  pharmacy_id (int FK), medicine_name (text), dosage (text),
                quantity (int), price (float)

No RPC function needed — queries the REST API directly.
"""

import os
import math
import httpx
import asyncio
from dataclasses import dataclass
from typing import Optional

# ── Supabase config (read at call-time for robustness) ──

def _get_url():
    return os.environ.get("SUPABASE_URL", "")

def _get_key():
    return os.environ.get("SUPABASE_ANON_KEY", "")


def _check_config():
    """Raise a clear error at call-time if env vars are missing."""
    if not _get_url() or not _get_key():
        raise RuntimeError(
            "SUPABASE_URL and SUPABASE_ANON_KEY environment variables must be set "
            "for pharmacy search to work."
        )


def _headers() -> dict:
    key = _get_key()
    return {
        "apikey": key,
        "Authorization": f"Bearer {key}",

        "Content-Type": "application/json",
    }


# ════════════════════════════════════════════════════
# DISTANCE CALCULATION (Haversine)
# ════════════════════════════════════════════════════

def _haversine_meters(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance in meters between two lat/lng points."""
    R = 6_371_000  # Earth radius in meters
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


# ════════════════════════════════════════════════════
# DATA STRUCTURES
# ════════════════════════════════════════════════════

@dataclass
class InventorySource:
    url: str
    key: str
    is_external: bool

@dataclass
class MatchedMedicine:
    medicine_name: str
    category: str
    quantity_available: int
    quantity_needed: int
    price: float


# ... (PharmacyResult and SearchResponse remain the same) ...

# ════════════════════════════════════════════════════
# THE SEARCH ALGORITHM
# ════════════════════════════════════════════════════

async def _fetch_from_source(
    client: httpx.AsyncClient, 
    source: InventorySource, 
    pharmacy_ids: list[int]
) -> list[dict]:
    """Fetch inventory from a specific Supabase source and normalize keys."""
    headers = {
        "apikey": source.key,
        "Authorization": f"Bearer {source.key}",
        "Content-Type": "application/json",
    }
    
    id_filter = ",".join(str(pid) for pid in pharmacy_ids)
    
    # We try to select both 'category,stock_quantity' and 'dosage,quantity' to be schema-agnostic
    params = {
        "pharmacy_id": f"in.({id_filter})",
        "select": "pharmacy_id,medicine_name,category,stock_quantity,dosage,quantity,price",
    }
    
    try:
        resp = await client.get(f"{source.url}/rest/v1/inventory", headers=headers, params=params)
        resp.raise_for_status()
        data = resp.json()
        
        # Normalize keys: move 'dosage'->'category' and 'quantity'->'stock_quantity' if needed
        for item in data:
            if "category" not in item or item["category"] is None:
                item["category"] = item.get("dosage", "Generic")
            if "stock_quantity" not in item or item["stock_quantity"] is None:
                item["stock_quantity"] = item.get("quantity", 0)
        return data
    except Exception as e:
        print(f"Error fetching from {source.url}: {e}")
        return []

async def search_pharmacies_by_names(
    latitude: float,
    longitude: float,
    medicine_names: list[dict],
    radius_meters: int = 7000,
) -> SearchResponse:
    _check_config()

    async with httpx.AsyncClient(timeout=15.0) as client:

        # ── Step 1: Fetch all pharmacies (including external DB info) ──
        # If the columns don't exist yet, this might error, so we handle it gracefully
        try:
            resp = await client.get(
                f"{_get_url()}/rest/v1/pharmacies",
                headers=_headers(),
                params={"select": "id,name,latitude,longitude,external_url,external_key"},
            )
            resp.raise_for_status()
            all_pharmacies = resp.json()
        except httpx.HTTPStatusError as e:
            # Fallback for if columns external_url/external_key aren't added yet
            resp = await client.get(
                f"{_get_url()}/rest/v1/pharmacies",
                headers=_headers(),
                params={"select": "id,name,latitude,longitude"},
            )
            resp.raise_for_status()
            all_pharmacies = resp.json()

        # ── Step 2: Filter by distance ──
        nearby = []
        for p in all_pharmacies:
            plat = float(p.get("latitude", 0))
            plng = float(p.get("longitude", 0))
            dist = _haversine_meters(latitude, longitude, plat, plng)
            if dist <= radius_meters:
                nearby.append({**p, "distance_meters": dist})

        nearby.sort(key=lambda x: x["distance_meters"])

        if not nearby:
            return SearchResponse(best_match=None, alternatives=[], partial_matches=[], 
                                suggestion="No pharmacies found within the search radius.")

        # ── Step 3: Group pharmacies by their inventory source ──
        sources: dict[str, tuple[InventorySource, list[int]]] = {}
        
        for p in nearby:
            ext_url = p.get("external_url")
            ext_key = p.get("external_key")
            
            if ext_url and ext_key:
                source_key = ext_url
                if source_key not in sources:
                    sources[source_key] = (InventorySource(ext_url, ext_key, True), [])
                sources[source_key][1].append(p["id"])
            else:
                # Use Master DB as default source
                source_key = "master"
                if source_key not in sources:
                    sources[source_key] = (InventorySource(_get_url(), _get_key(), False), [])
                sources[source_key][1].append(p["id"])

        # ── Step 4: Fetch inventory from all sources in parallel ──
        tasks = [
            _fetch_from_source(client, src_info[0], src_info[1])
            for src_info in sources.values()
        ]
        all_inventory_chunks = await asyncio.gather(*tasks)
        
        # Flatten the results
        all_inventory = [item for chunk in all_inventory_chunks for item in chunk]

    # ── Step 4: Build per-pharmacy inventory index ──
    # { pharmacy_id: [inventory_items...] }
    inventory_by_pharmacy: dict[int, list[dict]] = {}
    for item in all_inventory:
        pid = item["pharmacy_id"]
        if pid not in inventory_by_pharmacy:
            inventory_by_pharmacy[pid] = []
        inventory_by_pharmacy[pid].append(item)

    # ── Step 5: Match medicines per pharmacy ──
    results: list[PharmacyResult] = []

    for pharmacy in nearby:
        pid = pharmacy["id"]
        inv_items = inventory_by_pharmacy.get(pid, [])

        matched_items: list[MatchedMedicine] = []
        not_available: list[str] = []
        total_price = 0.0

        for med in medicine_names:
            drug_name = (med.get("drug_name") or "").strip()
            if not drug_name:
                continue

            needed_qty = _parse_quantity(med.get("quantity", "1"))

            # Try to find this medicine in the pharmacy's inventory
            match = _find_medicine_in_inventory(drug_name, inv_items)

            if match and match["stock_quantity"] > 0:
                actual_qty = min(match["stock_quantity"], needed_qty)
                item_price = float(match.get("price", 0)) * actual_qty
                matched_items.append(MatchedMedicine(
                    medicine_name=match["medicine_name"],
                    category=match.get("category", ""),
                    quantity_available=match["stock_quantity"],
                    quantity_needed=needed_qty,
                    price=item_price,
                ))
                total_price += item_price
            else:
                not_available.append(drug_name)

        total_required = len([m for m in medicine_names if (m.get("drug_name") or "").strip()])
        matched_count = len(matched_items)
        is_full = matched_count == total_required and total_required > 0

        results.append(PharmacyResult(
            pharmacy_id=pid,
            pharmacy_name=pharmacy["name"],
            distance_meters=pharmacy["distance_meters"],
            is_full_match=is_full,
            matched_count=matched_count,
            total_required=total_required,
            total_price=round(total_price, 2),
            items=matched_items,
            not_available=not_available,
        ))

    # ── Step 6: Sort and categorize ──
    # Full matches first, sorted by price then distance
    full_matches = sorted(
        [r for r in results if r.is_full_match],
        key=lambda r: (r.total_price, r.distance_meters),
    )
    partial_matches = sorted(
        [r for r in results if not r.is_full_match and r.matched_count > 0],
        key=lambda r: (-r.matched_count, r.total_price, r.distance_meters),
    )

    if full_matches:
        return SearchResponse(
            best_match=full_matches[0],
            alternatives=full_matches[1:],
            partial_matches=partial_matches,
            suggestion=None,
        )

    suggestion = _build_suggestion(partial_matches, total_required)
    return SearchResponse(
        best_match=None,
        alternatives=[],
        partial_matches=partial_matches,
        suggestion=suggestion,
    )


# ════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ════════════════════════════════════════════════════

def _parse_quantity(raw: str | int) -> int:
    """Parse quantity from OCR output — may be '10', '10 tablets', etc."""
    if isinstance(raw, int):
        return raw
    raw = str(raw).strip()
    try:
        return int("".join(c for c in raw if c.isdigit()) or "1")
    except ValueError:
        return 1


def _find_medicine_in_inventory(
    drug_name: str,
    inventory: list[dict],
) -> Optional[dict]:
    """
    Find a medicine in the pharmacy's inventory using fuzzy name matching.
    Strategy:
      1. Exact case-insensitive match
      2. Check if drug_name is contained in medicine_name (or vice versa)
      3. Match on first word (base drug name)
    """
    drug_lower = drug_name.lower().strip()
    base_name = drug_lower.split()[0] if drug_lower else ""

    # Strategy 1: Exact match
    for item in inventory:
        if item["medicine_name"].lower().strip() == drug_lower:
            return item

    # Strategy 2: Substring match (either direction)
    for item in inventory:
        inv_name = item["medicine_name"].lower().strip()
        if drug_lower in inv_name or inv_name in drug_lower:
            return item

    # Strategy 3: First-word match (base drug name)
    if base_name and len(base_name) > 3:
        for item in inventory:
            inv_name = item["medicine_name"].lower().strip()
            inv_base = inv_name.split()[0] if inv_name else ""
            if base_name == inv_base:
                return item

    return None


def _build_suggestion(partials: list[PharmacyResult], total: int) -> str:
    """Generate a helpful fallback message."""
    if not partials:
        return "No pharmacies found nearby with the requested medicines. Try increasing your search radius."

    best = partials[0]
    missing = total - best.matched_count

    if missing == 1:
        return (
            f"{best.pharmacy_name} has {best.matched_count}/{total} medicines. "
            f"1 medicine is unavailable — try an alternative brand or a second pharmacy."
        )

    return (
        f"No single pharmacy has all {total} medicines. "
        f"{best.pharmacy_name} covers {best.matched_count}/{total}. "
        f"Consider splitting your order across pharmacies."
    )


# ════════════════════════════════════════════════════
# JSON SERIALIZATION
# ════════════════════════════════════════════════════

def response_to_dict(resp: SearchResponse) -> dict:
    """Convert SearchResponse to a dict for JSON serialization."""

    def item_dict(item: MatchedMedicine) -> dict:
        return {
            "medicine_name": item.medicine_name,
            "category": item.category,
            "quantity_available": item.quantity_available,
            "quantity_needed": item.quantity_needed,
            "price": item.price,
        }

    def pharmacy_dict(p: PharmacyResult) -> dict:
        return {
            "pharmacy_id": p.pharmacy_id,
            "pharmacy_name": p.pharmacy_name,
            "distance_meters": round(p.distance_meters, 1),
            "is_full_match": p.is_full_match,
            "matched_count": p.matched_count,
            "total_required": p.total_required,
            "total_price": p.total_price,
            "items": [item_dict(i) for i in p.items],
            "not_available": p.not_available,
        }

    return {
        "best_match": pharmacy_dict(resp.best_match) if resp.best_match else None,
        "alternatives": [pharmacy_dict(a) for a in resp.alternatives],
        "partial_matches": [pharmacy_dict(p) for p in resp.partial_matches],
        "suggestion": resp.suggestion,
    }
