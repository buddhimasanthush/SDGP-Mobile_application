"""
medicine_resolver.py — Extracts clean medicine names + quantities from OCR output.

Since the actual Supabase schema uses medicine_name (text) in the inventory table
rather than UUIDs, this module simply cleans up OCR output into a format
suitable for the pharmacy search.
"""

import re
from typing import Optional


def extract_medicines_from_ocr(medications: list[dict]) -> list[dict]:
    """
    Takes the raw medications list from OCR output and cleans it up
    for pharmacy search.

    Input example:
        [{"drug_name": "Amoxicillin 500mg capsule", "quantity": "10", ...}]

    Output:
        [{"drug_name": "Amoxicillin", "quantity": 10, "original_name": "Amoxicillin 500mg capsule"}]
    """
    results = []

    for med in medications:
        drug_name = (med.get("drug_name") or "").strip()
        if not drug_name:
            continue

        # Parse quantity
        raw_qty = str(med.get("quantity", "1")).strip()
        try:
            quantity = int("".join(c for c in raw_qty if c.isdigit()) or "1")
        except ValueError:
            quantity = 1

        results.append({
            "drug_name": drug_name,
            "quantity": quantity,
            "original_name": drug_name,
        })

    return results
