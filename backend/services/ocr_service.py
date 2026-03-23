import os
import json
import time
import re
from pathlib import Path
from typing import Optional, List

import easyocr
from PIL import Image, ImageEnhance, ImageFilter

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
