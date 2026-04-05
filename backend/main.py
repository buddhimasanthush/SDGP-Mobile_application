import os
from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn
import shutil
from typing import Optional

from services.ocr_service import process_prescription_image

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


# ═══════════════════════════════════════════════════════
# OCR Endpoint
# ═══════════════════════════════════════════════════════

@app.post("/api/ocr/upload")
def upload_prescription(file: UploadFile = File(...)):
    """
    Endpoint to process prescription images using OCR (EasyOCR + DeepSeek fallback).
    Runs synchronously so FastAPI offloads it to a background threadpool.
    """
    filename_lower = (file.filename or "").lower()
    if not any(filename_lower.endswith(ext) for ext in ['.png', '.jpg', '.jpeg']):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload a JPG or PNG image.")

    import tempfile
    with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(filename_lower)[1]) as tmp:
        shutil.copyfileobj(file.file, tmp)
        temp_file_path = tmp.name

    try:
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


# ═══════════════════════════════════════════════════════
# Pharmacy Search Endpoints
# ═══════════════════════════════════════════════════════

class MedicationInput(BaseModel):
    drug_name: str
    quantity: str = "1"
    strength: Optional[str] = None
    dosage_form: Optional[str] = None
    instructions: Optional[str] = None
    frequency: Optional[str] = None
    duration: Optional[str] = None


class PrescriptionSearchRequest(BaseModel):
    latitude: float
    longitude: float
    medications: list[MedicationInput]
    radius_meters: int = 7000


@app.post("/api/pharmacy/search")
async def pharmacy_search(req: PrescriptionSearchRequest):
    """
    Search nearby pharmacies for medicines.
    Accepts medicine names (from OCR or manual input) and user location.
    Queries the Supabase pharmacies + inventory tables directly.
    """
    try:
        from search.pharmacy_search import search_pharmacies_by_names, response_to_dict
        from search.medicine_resolver import extract_medicines_from_ocr

        # Clean up the medication list
        medications = [m.model_dump() for m in req.medications]
        cleaned = extract_medicines_from_ocr(medications)

        if not cleaned:
            raise HTTPException(status_code=400, detail="No valid medicine names provided.")

        # Run the search
        result = await search_pharmacies_by_names(
            latitude=req.latitude,
            longitude=req.longitude,
            medicine_names=cleaned,
            radius_meters=req.radius_meters,
        )

        return response_to_dict(result)

    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Pharmacy search failed: {str(e)}")


@app.post("/api/pharmacy/search-by-prescription")
async def pharmacy_search_by_prescription(req: PrescriptionSearchRequest):
    """
    Alias for /api/pharmacy/search — same logic.
    Takes OCR medication output + user location, searches pharmacies.
    """
    return await pharmacy_search(req)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
