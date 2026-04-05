import os
import json
import base64
import time
import re
from pathlib import Path
from typing import Optional, List

import easyocr
from openai import OpenAI
from PIL import Image, ImageEnhance, ImageFilter

# ── DeepSeek Configuration ────────────────────────────────────────────────────
DEEPSEEK_API_KEY = os.environ.get("DEEPSEEK_API_KEY")
DEEPSEEK_BASE_URL = "https://api.deepseek.com"
DEEPSEEK_MODEL = "deepseek-chat"

if not DEEPSEEK_API_KEY:
    print("WARNING: DEEPSEEK_API_KEY not found in environment!")
else:
    print(f"DeepSeek OCR initialized with key: {DEEPSEEK_API_KEY[:6]}...{DEEPSEEK_API_KEY[-4:]}")

# Initialise OpenAI-compatible client pointed at DeepSeek
client = OpenAI(api_key=DEEPSEEK_API_KEY, base_url=DEEPSEEK_BASE_URL)

MAX_RETRIES = 2

EXTRACTION_PROMPT = """You are an expert pharmacist AI.
You will be given OCR text extracted from a medical prescription image.
Extract ALL information and return a single JSON object matching this structure exactly:

{
  "confidence": "high",
  "prescriber": { "name": null, "specialty": null, "contact": null },
  "patient": { "name": null, "age": null, "gender": null },
  "diagnosis_notes": "",
  "medications": [
    {
      "drug_name": "Medicine Name",
      "strength": "500mg",
      "dosage_form": "tablet",
      "instructions": "Take after food",
      "frequency": "twice daily",
      "duration": "5 days",
      "quantity": "10"
    }
  ]
}

Rules:
- Expand abbreviations: OD=once daily, BD/BID=twice daily, TDS/TID=three times daily, QID=four times daily, SOS=when needed
- Use null for any field you cannot determine
- If no medications are found, return an empty medications list []
- Return ONLY the JSON object, no extra text or markdown fences
"""

# ── EasyOCR Reader (lazy singleton) ──────────────────────────────────────────
_easyocr_reader = None

def _get_easyocr_reader():
    global _easyocr_reader
    if _easyocr_reader is None:
        _easyocr_reader = easyocr.Reader(['en'], gpu=False, verbose=False)
    return _easyocr_reader


# ── Image pre-processing ─────────────────────────────────────────────────────
def preprocess_image(image_path: str) -> str:
    img = Image.open(image_path).convert("RGB")
    w, h = img.size
    if max(w, h) < 1000:
        scale = 1000 / max(w, h)
        try:
            resample_method = Image.Resampling.LANCZOS
        except AttributeError:
            resample_method = Image.LANCZOS
        img = img.resize((int(w * scale), int(h * scale)), resample_method)

    img_grey = img.convert("L")
    img_sharp = img_grey.filter(ImageFilter.SHARPEN)
    img_contrast = ImageEnhance.Contrast(img_sharp).enhance(2.0)

    out_path = image_path + "_processed.png"
    img_contrast.save(out_path)
    return out_path


# ── OCR text extraction ──────────────────────────────────────────────────────
def extract_text_easyocr(image_path: str) -> str:
    try:
        reader = _get_easyocr_reader()
        results = reader.readtext(image_path, detail=1, paragraph=False)
        lines = [text for (_, text, conf) in results if conf > 0.30]
        return " ".join(lines).strip()
    except Exception as e:
        print(f"EasyOCR error: {e}")
        return ""


# ── DeepSeek structured extraction ───────────────────────────────────────────
def extract_with_deepseek(ocr_text: str, retries: int = MAX_RETRIES) -> dict:
    """Send OCR text to DeepSeek chat model and return parsed JSON."""
    if not ocr_text.strip():
        return {"error": "No text extracted from image"}

    user_message = (
        f"Here is the OCR text extracted from a prescription image:\n\n"
        f"---\n{ocr_text}\n---\n\n"
        f"Please extract all medicine and prescription details into the JSON format described."
    )

    for attempt in range(1, retries + 2):
        try:
            print(f"DeepSeek attempt {attempt}...")
            response = client.chat.completions.create(
                model=DEEPSEEK_MODEL,
                messages=[
                    {"role": "system", "content": EXTRACTION_PROMPT},
                    {"role": "user",   "content": user_message},
                ],
                temperature=0.1,
                max_tokens=2048,
                timeout=45.0,  # Enforce a strict 45-second timeout to prevent infinite hangs
            )

            raw_text = response.choices[0].message.content.strip()
            print(f"DeepSeek raw response ({len(raw_text)} chars)")

            # Strip markdown code fences if present
            if raw_text.startswith("```"):
                raw_text = re.sub(r'^```(?:json)?\s*', '', raw_text)
                raw_text = re.sub(r'\s*```$', '', raw_text).strip()

            return json.loads(raw_text)

        except json.JSONDecodeError as je:
            print(f"DeepSeek JSON parse error: {je}")
            if attempt <= retries:
                time.sleep(2)
                continue
            return {"error": f"Failed to parse DeepSeek response as JSON"}

        except Exception as e:
            err_str = str(e)
            print(f"DeepSeek attempt {attempt} error: {err_str}")
            if "429" in err_str or "rate" in err_str.lower():
                if attempt <= retries:
                    time.sleep(5 * attempt)
                    continue
                return {"error": "QUOTA_EXCEEDED"}
            if attempt <= retries:
                time.sleep(3)
                continue
            return {"error": f"DeepSeek failed: {err_str}"}

    return {"error": "DeepSeek failed after all retries"}


# ── Heuristic fallback parser ─────────────────────────────────────────────────
def build_medicines_from_ocr_text(ocr_text: str) -> dict:
    """Last-resort fallback: heuristically parse medicines from OCR text."""
    medicines = []
    med_keywords = ["mg", "ml", "tablet", "capsule", "syrup", "tab", "cap",
                    "injection", "drops", "cream", "ointment"]

    raw_lines = re.split(r'[,;\n]', ocr_text)

    seen = set()
    for line in raw_lines:
        line = line.strip()
        if any(kw in line.lower() for kw in med_keywords) and len(line) > 4:
            if line not in seen:
                seen.add(line)
                medicines.append({
                    "drug_name": line,
                    "strength": "",
                    "dosage_form": "tablet",
                    "instructions": "As directed by doctor",
                    "frequency": "As directed",
                    "duration": "As directed",
                    "quantity": "1"
                })

    if not medicines:
        tokens = [t for t in ocr_text.split() if len(t) > 4][:5]
        for t in tokens:
            medicines.append({
                "drug_name": t,
                "strength": "",
                "dosage_form": "tablet",
                "instructions": "As directed by doctor",
                "frequency": "As directed",
                "duration": "As directed",
                "quantity": "1"
            })

    return {
        "confidence": "low",
        "prescriber": None,
        "patient": None,
        "diagnosis_notes": "Extracted using OCR fallback",
        "medications": medicines
    }


# ── Main pipeline ─────────────────────────────────────────────────────────────
def process_prescription_image(image_path: str) -> dict:
    """Process an uploaded prescription: EasyOCR -> DeepSeek -> fallback."""
    processed_path = None
    try:
        # Step 1: pre-process & EasyOCR
        processed_path = preprocess_image(image_path)
        ocr_text = extract_text_easyocr(processed_path)
        print(f"EasyOCR extracted {len(ocr_text)} chars: {ocr_text[:200]}")

        if not ocr_text.strip():
            return {
                "confidence": "none",
                "diagnosis_notes": "Could not read any text from the image. Please try a clearer photo.",
                "medications": []
            }

        # Step 2: send OCR text to DeepSeek for structured extraction
        result = extract_with_deepseek(ocr_text)

        # Step 3: if DeepSeek failed, fall back to heuristic parser
        if isinstance(result, dict) and "error" in result:
            print(f"DeepSeek error: {result['error']}  ->  using heuristic fallback")
            result = build_medicines_from_ocr_text(ocr_text)

        # Ensure required fields
        if "medications" not in result:
            result["medications"] = []
        if "diagnosis_notes" not in result:
            result["diagnosis_notes"] = ""

        return result

    except Exception as e:
        print(f"Error in process_prescription_image: {e}")
        return {"error": str(e)}
    finally:
        if processed_path and os.path.exists(processed_path):
            try:
                os.remove(processed_path)
            except Exception:
                pass
