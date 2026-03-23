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
