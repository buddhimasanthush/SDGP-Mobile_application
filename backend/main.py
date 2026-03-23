from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import os
import shutil

from services.ocr_service import process_prescription_image

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

app = FastAPI(title="MediFind Backend API")

# CORS — allow the Android emulator and web to reach the backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the MediFind Python Backend API!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

# OCR Endpoint — no strict auth required for dev; add back when in production
@app.post("/api/ocr/upload")
async def upload_prescription(file: UploadFile = File(...)):
    """
    Endpoint to process prescription images using OCR (Gemini + EasyOCR fallback).
    """
    filename_lower = (file.filename or "").lower()
    if not any(filename_lower.endswith(ext) for ext in ['.png', '.jpg', '.jpeg']):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload a JPG or PNG image.")

    temp_file_path = f"temp_{file.filename}"
    try:
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Process with OCR pipeline (Gemini with EasyOCR fallback)
        result = process_prescription_image(temp_file_path)

        if isinstance(result, dict) and "error" in result and "medications" not in result:
            raise HTTPException(status_code=500, detail=f"OCR Processing failed: {result['error']}")

        return {
            "filename": file.filename,
            "data": result
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")
    finally:
        if os.path.exists(temp_file_path):
            try:
                os.remove(temp_file_path)
            except Exception:
                pass

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
