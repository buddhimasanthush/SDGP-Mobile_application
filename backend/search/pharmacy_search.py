"""
pharmacy_search.py — The complete pharmacy search algorithm.

This is the ONLY file that contains the search logic.
It calls one Supabase RPC function and processes the result.

Deploy on Railway with your existing Python backend.
"""

import os
import httpx
from dataclasses import dataclass

# ── Supabase config (set these as Railway environment variables) ──
SUPABASE_URL = os.environ["SUPABASE_URL"]       # https://xxxxx.supabase.co
SUPABASE_KEY = os.environ["SUPABASE_ANON_KEY"]  # your anon/service key


# ════════════════════════════════════════════════════
# DATA STRUCTURES
# ════════════════════════════════════════════════════

@dataclass
class MedicineRequest:
    medicine_id: str   # UUID of the generic medicine
    quantity: int      # how many units needed


@dataclass
class SelectedItem:
    medicine_id: str
    brand_id: str
    brand_name: str
    price: float
    quantity: int


@dataclass
class PharmacyResult:
    pharmacy_id: str
    pharmacy_name: str
    distance_meters: float
    is_full_match: bool
    matched_medicines: int
    total_required: int
    total_price: float
    items: list[SelectedItem]


@dataclass
class SearchResponse:
    best_match: PharmacyResult | None
    alternatives: list[PharmacyResult]
    partial_matches: list[PharmacyResult]
    suggestion: str | None


# ════════════════════════════════════════════════════
# THE ALGORITHM
# ════════════════════════════════════════════════════

async def search_pharmacies(
    latitude: float,
    longitude: float,
    medicines: list[MedicineRequest],
    radius_meters: int = 7000,
) -> SearchResponse:
    """
    Find the best pharmacy for a list of medicines.

    How it works:
    1. Calls ONE Supabase RPC function (search_pharmacies)
    2. That function does ALL the heavy lifting in PostgreSQL:
       - Finds nearby open pharmacies (PostGIS spatial index)
       - Joins inventory + brands tables
       - Picks cheapest brand per medicine per pharmacy
       - Checks stock quantity
       - Aggregates total price
       - Sorts by full match → price → distance
    3. Python just splits the results into categories

    Performance:
    - 1 database round-trip (not N per pharmacy)
    - All filtering uses indexes (no table scans)
    - Handles 50,000+ medicines × 100+ pharmacies
    """

    med_ids = [m.medicine_id for m in medicines]
    med_qtys = [m.quantity for m in medicines]
    total_meds = len(medicines)

    # ── Call Supabase RPC ──
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{SUPABASE_URL}/rest/v1/rpc/search_pharmacies",
            headers={
                "apikey": SUPABASE_KEY,
                "Authorization": f"Bearer {SUPABASE_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "user_lng": longitude,
                "user_lat": latitude,
                "radius_m": radius_meters,
                "med_ids": med_ids,
                "med_qtys": med_qtys,
                "total_meds": total_meds,
                "max_results": 10,
            },
            timeout=15.0,
        )
        response.raise_for_status()
        rows = response.json()

    # ── Process results ──
    full_matches: list[PharmacyResult] = []
    partial_matches: list[PharmacyResult] = []

    for row in rows:
        items = [
            SelectedItem(
                medicine_id=item["medicine_id"],
                brand_id=item["brand_id"],
                brand_name=item["brand_name"],
                price=float(item["price"]),
                quantity=int(item["quantity"]),
            )
            for item in row["items"]
        ]

        result = PharmacyResult(
            pharmacy_id=row["pharmacy_id"],
            pharmacy_name=row["pharmacy_name"],
            distance_meters=float(row["distance_meters"]),
            is_full_match=bool(row["is_full_match"]),
            matched_medicines=int(row["matched_medicines"]),
            total_required=int(row["total_required"]),
            total_price=float(row["total_price"]),
            items=items,
        )

        if result.is_full_match:
            full_matches.append(result)
        else:
            partial_matches.append(result)

    # ── Build response ──
    if full_matches:
        return SearchResponse(
            best_match=full_matches[0],
            alternatives=full_matches[1:],
            partial_matches=[],
            suggestion=None,
        )

    # No full match — generate suggestion
    suggestion = _build_suggestion(partial_matches, total_meds)
    return SearchResponse(
        best_match=None,
        alternatives=[],
        partial_matches=partial_matches,
        suggestion=suggestion,
    )


def _build_suggestion(partials: list[PharmacyResult], total: int) -> str:
    """Generate a helpful fallback message."""
    if not partials:
        return "No pharmacies found nearby with the requested medicines. Try increasing your search radius."

    best = partials[0]
    missing = total - best.matched_medicines

    if missing == 1:
        return (
            f"{best.pharmacy_name} has {best.matched_medicines}/{total} medicines. "
            f"1 medicine is unavailable — try an alternative brand or a second pharmacy."
        )

    return (
        f"No single pharmacy has all {total} medicines. "
        f"{best.pharmacy_name} covers {best.matched_medicines}/{total}. "
        f"Consider splitting your order across pharmacies."
    )
