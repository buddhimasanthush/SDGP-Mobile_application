import asyncio
import json
import os
import re
import threading
from pathlib import Path
from typing import Any

from openai import OpenAI
from PIL import Image, ImageEnhance, ImageFilter

# DeepSeek configuration
DEEPSEEK_API_KEY = os.environ.get("DEEPSEEK_API_KEY")
DEEPSEEK_BASE_URL = "https://api.deepseek.com"
DEEPSEEK_MODEL = "deepseek-chat"
DEEPSEEK_TIMEOUT_SECONDS = float(os.environ.get("DEEPSEEK_TIMEOUT_SECONDS", "45"))
MAX_RETRIES = int(os.environ.get("DEEPSEEK_MAX_RETRIES", "2"))

# OCR configuration
EASYOCR_ENABLED = os.environ.get("EASYOCR_ENABLED", "true").strip().lower() in {
    "1",
    "true",
    "yes",
    "on",
}
EASYOCR_TIMEOUT_SECONDS = int(os.environ.get("EASYOCR_TIMEOUT_SECONDS", "20"))
EASYOCR_MIN_CONFIDENCE = float(os.environ.get("EASYOCR_MIN_CONFIDENCE", "0.20"))
EASYOCR_MIN_CONFIDENCE_PROCESSED = float(
    os.environ.get("EASYOCR_MIN_CONFIDENCE_PROCESSED", str(EASYOCR_MIN_CONFIDENCE))
)
EASYOCR_MIN_CONFIDENCE_ORIGINAL = float(
    os.environ.get("EASYOCR_MIN_CONFIDENCE_ORIGINAL", str(EASYOCR_MIN_CONFIDENCE))
)
EASYOCR_ACCEPT_MIN_CHARS = int(os.environ.get("EASYOCR_ACCEPT_MIN_CHARS", "50"))
EASYOCR_ACCEPT_MIN_WORDS = int(os.environ.get("EASYOCR_ACCEPT_MIN_WORDS", "8"))

if not DEEPSEEK_API_KEY:
    print("WARNING: DEEPSEEK_API_KEY not found in environment.")

client = OpenAI(api_key=DEEPSEEK_API_KEY, base_url=DEEPSEEK_BASE_URL)

_easyocr_reader: Any | None = None
_easyocr_lock = threading.Lock()

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


def _default_response() -> dict:
    return {
        "confidence": "none",
        "prescriber": {"name": None, "specialty": None, "contact": None},
        "patient": {"name": None, "age": None, "gender": None},
        "diagnosis_notes": "",
        "medications": [],
    }


def _merge_response(payload: dict | None = None, **overrides: Any) -> dict:
    merged = _default_response()
    if payload:
        merged.update(payload)
    merged.update(overrides)
    if merged.get("prescriber") is None:
        merged["prescriber"] = {"name": None, "specialty": None, "contact": None}
    if merged.get("patient") is None:
        merged["patient"] = {"name": None, "age": None, "gender": None}
    if "medications" not in merged or merged["medications"] is None:
        merged["medications"] = []
    if "diagnosis_notes" not in merged or merged["diagnosis_notes"] is None:
        merged["diagnosis_notes"] = ""
    return merged


def _get_easyocr_reader():
    global _easyocr_reader
    if _easyocr_reader is not None:
        return _easyocr_reader

    with _easyocr_lock:
        if _easyocr_reader is None:
            import easyocr

            _easyocr_reader = easyocr.Reader(["en"], gpu=False, verbose=False)
            print("EasyOCR reader initialized.")
    return _easyocr_reader


async def initialize_ocr() -> None:
    if not EASYOCR_ENABLED:
        print("EasyOCR warmup skipped: EASYOCR_ENABLED=false")
        return
    await asyncio.to_thread(_get_easyocr_reader)


def _preprocess_image_sync(image_path: str, processed_path: str) -> str:
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
    img_contrast.save(processed_path)
    return processed_path


async def preprocess_image(image_path: str, processed_path: str) -> str:
    return await asyncio.to_thread(_preprocess_image_sync, image_path, processed_path)


def _word_quality_metrics(text: str) -> tuple[int, int]:
    words = re.findall(r"[A-Za-z0-9]{2,}", text)
    useful_words = [w for w in words if len(w) > 3]
    return len(words), len(useful_words)


def _extract_text_easyocr_sync(image_path: str, min_conf: float) -> dict:
    reader = _get_easyocr_reader()
    raw_results = reader.readtext(image_path, detail=1, paragraph=True)

    accepted_texts: list[str] = []
    accepted_conf: list[float] = []
    for _, text, conf in raw_results:
        if conf < min_conf:
            continue
        text_value = (text or "").strip()
        if not text_value:
            continue
        accepted_texts.append(text_value)
        accepted_conf.append(float(conf))

    joined = " ".join(accepted_texts).strip()
    all_words, useful_words = _word_quality_metrics(joined)
    avg_conf = (sum(accepted_conf) / len(accepted_conf)) if accepted_conf else 0.0
    quality_score = useful_words * avg_conf
    return {
        "text": joined,
        "avg_conf": avg_conf,
        "word_count": all_words,
        "useful_word_count": useful_words,
        "quality_score": quality_score,
    }


async def extract_text_easyocr(image_path: str, min_conf: float) -> dict:
    if not EASYOCR_ENABLED:
        return {
            "text": "",
            "avg_conf": 0.0,
            "word_count": 0,
            "useful_word_count": 0,
            "quality_score": 0.0,
        }
    try:
        return await asyncio.wait_for(
            asyncio.to_thread(_extract_text_easyocr_sync, image_path, min_conf),
            timeout=EASYOCR_TIMEOUT_SECONDS,
        )
    except asyncio.TimeoutError:
        print(f"EasyOCR timeout on {image_path} after {EASYOCR_TIMEOUT_SECONDS}s")
        return {
            "text": "",
            "avg_conf": 0.0,
            "word_count": 0,
            "useful_word_count": 0,
            "quality_score": 0.0,
        }
    except Exception as exc:
        print(f"EasyOCR error on {image_path}: {exc}")
        return {
            "text": "",
            "avg_conf": 0.0,
            "word_count": 0,
            "useful_word_count": 0,
            "quality_score": 0.0,
        }


async def extract_best_ocr_text(original_image_path: str, processed_image_path: str) -> str:
    processed = await extract_text_easyocr(
        processed_image_path, EASYOCR_MIN_CONFIDENCE_PROCESSED
    )
    processed_text = processed["text"]
    if (
        len(processed_text) >= EASYOCR_ACCEPT_MIN_CHARS
        and processed["useful_word_count"] >= EASYOCR_ACCEPT_MIN_WORDS
    ):
        print(
            f"OCR accepted processed image directly (chars={len(processed_text)}, "
            f"useful_words={processed['useful_word_count']}, avg_conf={processed['avg_conf']:.3f})"
        )
        return processed_text

    original = await extract_text_easyocr(
        original_image_path, EASYOCR_MIN_CONFIDENCE_ORIGINAL
    )

    # Use meaningful quality score, not raw character length.
    candidates = [("processed", processed), ("original", original)]
    best_name, best_payload = max(candidates, key=lambda item: item[1]["quality_score"])
    print(
        f"OCR selected {best_name} image "
        f"(score={best_payload['quality_score']:.3f}, "
        f"useful_words={best_payload['useful_word_count']}, "
        f"avg_conf={best_payload['avg_conf']:.3f})"
    )
    return best_payload["text"]


async def extract_with_deepseek(ocr_text: str, retries: int = MAX_RETRIES) -> dict:
    if not ocr_text.strip():
        return {"error": "No text extracted from image"}
    if not DEEPSEEK_API_KEY:
        return {"error": "DeepSeek API key not configured"}

    user_message = (
        "Here is the OCR text extracted from a prescription image:\n\n"
        f"---\n{ocr_text}\n---\n\n"
        "Please extract all medicine and prescription details into the JSON format described."
    )

    for attempt in range(1, retries + 2):
        try:
            print(f"DeepSeek attempt {attempt}...")
            response = await asyncio.wait_for(
                asyncio.to_thread(
                    client.chat.completions.create,
                    model=DEEPSEEK_MODEL,
                    messages=[
                        {"role": "system", "content": EXTRACTION_PROMPT},
                        {"role": "user", "content": user_message},
                    ],
                    temperature=0.1,
                    max_tokens=2048,
                    timeout=DEEPSEEK_TIMEOUT_SECONDS,
                ),
                timeout=DEEPSEEK_TIMEOUT_SECONDS + 5,
            )

            raw_text = (response.choices[0].message.content or "").strip()
            print(f"DeepSeek raw response chars={len(raw_text)}")

            if raw_text.startswith("```"):
                raw_text = re.sub(r"^```(?:json)?\s*", "", raw_text)
                raw_text = re.sub(r"\s*```$", "", raw_text).strip()

            parsed = json.loads(raw_text)
            return parsed if isinstance(parsed, dict) else {"error": "DeepSeek response is not an object"}
        except json.JSONDecodeError:
            if attempt <= retries:
                await asyncio.sleep(2)
                continue
            return {"error": "Failed to parse DeepSeek response as JSON"}
        except Exception as exc:
            err_str = str(exc)
            print(f"DeepSeek attempt {attempt} error: {err_str}")
            if "429" in err_str or "rate" in err_str.lower():
                if attempt <= retries:
                    await asyncio.sleep(5 * attempt)
                    continue
                return {"error": "QUOTA_EXCEEDED"}
            if attempt <= retries:
                await asyncio.sleep(3)
                continue
            return {"error": f"DeepSeek failed: {err_str}"}
    return {"error": "DeepSeek failed after all retries"}


def build_medicines_from_ocr_text(ocr_text: str) -> dict:
    medicines = []
    med_keywords = [
        "mg",
        "ml",
        "tablet",
        "capsule",
        "syrup",
        "tab",
        "cap",
        "injection",
        "drops",
        "cream",
        "ointment",
    ]
    raw_lines = re.split(r"[,;\n]", ocr_text)
    seen = set()
    for line in raw_lines:
        line = line.strip()
        if any(kw in line.lower() for kw in med_keywords) and len(line) > 4 and line not in seen:
            seen.add(line)
            medicines.append(
                {
                    "drug_name": line,
                    "strength": "",
                    "dosage_form": "tablet",
                    "instructions": "As directed by doctor",
                    "frequency": "As directed",
                    "duration": "As directed",
                    "quantity": "1",
                }
            )

    if not medicines:
        tokens = [t for t in ocr_text.split() if len(t) > 4][:5]
        for token in tokens:
            medicines.append(
                {
                    "drug_name": token,
                    "strength": "",
                    "dosage_form": "tablet",
                    "instructions": "As directed by doctor",
                    "frequency": "As directed",
                    "duration": "As directed",
                    "quantity": "1",
                }
            )

    return _merge_response(
        {
            "confidence": "low",
            "diagnosis_notes": "Extracted using OCR fallback",
            "medications": medicines,
        }
    )


async def process_prescription_image(image_path: str) -> dict:
    image = Path(image_path)
    processed_image = Path(f"{image_path}_processed.png")
    files_to_cleanup = [processed_image]

    # Validate upload before any heavy processing.
    if not image.exists():
        return _merge_response(error="Uploaded image file not found.", status_code=400)
    if image.stat().st_size <= 0:
        return _merge_response(error="Uploaded image file is empty.", status_code=400)
    try:
        with Image.open(image_path) as img:
            img.verify()
    except Exception:
        return _merge_response(error="Uploaded file is not a valid image.", status_code=400)

    try:
        await preprocess_image(image_path, str(processed_image))
        ocr_text = await extract_best_ocr_text(image_path, str(processed_image))
        print(f"OCR extracted chars={len(ocr_text)}")

        if not ocr_text.strip():
            return _merge_response(
                {
                    "confidence": "none",
                    "diagnosis_notes": "Could not read any text from the image. Please try a clearer photo.",
                    "medications": [],
                },
                error="Could not read any text from the image. Please try a clearer photo.",
                status_code=422,
            )

        result = await extract_with_deepseek(ocr_text)
        if isinstance(result, dict) and "error" in result:
            print(f"DeepSeek error: {result['error']} -> using heuristic fallback")
            result = build_medicines_from_ocr_text(ocr_text)

        normalized = _merge_response(result)
        if not normalized["medications"]:
            return _merge_response(
                normalized,
                error="Could not detect medicines from this image.",
                status_code=422,
            )
        return normalized
    except Exception as exc:
        return _merge_response(error=f"OCR pipeline failed: {exc}", status_code=500)
    finally:
        for path in files_to_cleanup:
            try:
                if path.exists():
                    path.unlink()
            except Exception:
                pass
