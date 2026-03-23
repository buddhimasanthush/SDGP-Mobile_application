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

# -- DeepSeek Configuration --
DEEPSEEK_API_KEY = os.environ.get(
    "DEEPSEEK_API_KEY",
    "sk-12fbe20606204e60b32133f19993ec70"
)
DEEPSEEK_BASE_URL = "https://api.deepseek.com"
DEEPSEEK_MODEL = "deepseek-chat"

# Initialise OpenAI-compatible client pointed at DeepSeek
client = OpenAI(api_key=DEEPSEEK_API_KEY, base_url=DEEPSEEK_BASE_URL)

MAX_RETRIES = 2

# -- EasyOCR Reader (lazy singleton) --
_easyocr_reader = None

def _get_easyocr_reader():
    global _easyocr_reader
    if _easyocr_reader is None:
        _easyocr_reader = easyocr.Reader(['en'], gpu=False, verbose=False)
    return _easyocr_reader


# -- Image pre-processing --
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


# -- OCR text extraction --
def extract_text_easyocr(image_path: str) -> str:
    try:
        reader = _get_easyocr_reader()
        results = reader.readtext(image_path, detail=1, paragraph=False)
        lines = [text for (_, text, conf) in results if conf > 0.30]
        return " ".join(lines).strip()
    except Exception as e:
        print(f"EasyOCR error: {e}")
        return ""
