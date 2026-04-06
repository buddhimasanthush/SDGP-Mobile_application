import os
import logging
import tempfile
import time
import uuid
from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, HTTPException, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, Field
from starlette.responses import JSONResponse
import uvicorn
from typing import Optional

from services.ocr_service import initialize_ocr, process_prescription_image
from services.password_reset_service import PasswordResetService

app = FastAPI(title="MediFind Backend API")
_password_reset_service: PasswordResetService | None = None
logger = logging.getLogger("medifind.api")
MAX_UPLOAD_BYTES = int(float(os.environ.get("OCR_MAX_UPLOAD_MB", "12")) * 1024 * 1024)
ALLOWED_IMAGE_CONTENT_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/pjpeg",
    "image/png",
}
ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def _get_password_reset_service() -> PasswordResetService:
    global _password_reset_service
    if _password_reset_service is None:
        _password_reset_service = PasswordResetService()
    return _password_reset_service

def _cors_origins() -> list[str]:
    raw = os.environ.get("CORS_ORIGINS", "").strip()
    if raw:
        return [o.strip() for o in raw.split(",") if o.strip()]
    # Safe defaults for local development only.
    return [
        "http://127.0.0.1:8000",
        "http://10.0.2.2:8000",
        "http://localhost:3000",
    ]


app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def request_validation_exception_handler(
    request: Request, exc: RequestValidationError
):
    validation_errors = []
    for err in exc.errors():
        loc = err.get("loc", [])
        field = loc[-1] if loc else "unknown"
        validation_errors.append(
            {
                "field": str(field),
                "message": err.get("msg", "Validation error"),
                "type": err.get("type", "value_error"),
            }
        )

    logger.warning(
        "422 request validation failed method=%s path=%s content_type=%s errors=%s",
        request.method,
        request.url.path,
        request.headers.get("content-type"),
        validation_errors,
    )
    return JSONResponse(
        status_code=422,
        content={
            "detail": "Request validation failed",
            "validation_errors": validation_errors,
            "expected": {
                "content_type": "multipart/form-data",
                "file_fields": ["file", "image", "prescription", "photo"],
            },
        },
    )


def _pick_upload_file(*candidates: UploadFile | None) -> UploadFile | None:
    for candidate in candidates:
        if candidate is not None:
            return candidate
    return None

@app.get("/")
def read_root():
    return {"message": "Welcome to the MediFind Python Backend API!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.on_event("startup")
async def startup_event():
    try:
        await initialize_ocr()
    except Exception as exc:
        # Keep service available even if OCR warmup fails; endpoint will return explicit errors.
        print(f"OCR warmup failed at startup: {exc}")


# ═══════════════════════════════════════════════════════
# OCR Endpoint
# ═══════════════════════════════════════════════════════

@app.post("/api/ocr/upload")
async def upload_prescription(
    request: Request,
    file: UploadFile | None = File(default=None),
    image: UploadFile | None = File(default=None),
    prescription: UploadFile | None = File(default=None),
    photo: UploadFile | None = File(default=None),
):
    """
    Endpoint to process prescription images using OCR (EasyOCR + DeepSeek fallback).
    Runs synchronously so FastAPI offloads it to a background threadpool.
    """
    request_id = str(uuid.uuid4())
    started_at = time.perf_counter()
    upload = _pick_upload_file(file, image, prescription, photo)

    if upload is None:
        raise HTTPException(
            status_code=422,
            detail={
                "message": "No upload file was provided.",
                "validation": {
                    "field": "file",
                    "accepted_field_names": ["file", "image", "prescription", "photo"],
                    "expected_content_type": "multipart/form-data",
                },
            },
        )

    original_filename = upload.filename or "upload"
    filename_lower = original_filename.lower()
    ext = os.path.splitext(filename_lower)[1]
    content_type = (upload.content_type or "").lower()

    file_bytes = await upload.read()
    file_size = len(file_bytes)
    if file_size <= 0:
        raise HTTPException(
            status_code=400,
            detail={
                "message": "Uploaded image file is empty.",
                "validation": {"field": "file", "size_bytes": file_size},
            },
        )
    if file_size > MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=413,
            detail={
                "message": "Uploaded file is too large.",
                "validation": {
                    "field": "file",
                    "size_bytes": file_size,
                    "max_bytes": MAX_UPLOAD_BYTES,
                },
            },
        )

    if ext not in ALLOWED_IMAGE_EXTENSIONS and content_type not in ALLOWED_IMAGE_CONTENT_TYPES:
        raise HTTPException(
            status_code=400,
            detail={
                "message": "Invalid file type. Please upload a JPG or PNG image.",
                "validation": {
                    "field": "file",
                    "filename": original_filename,
                    "content_type": content_type,
                    "allowed_extensions": sorted(ALLOWED_IMAGE_EXTENSIONS),
                    "allowed_content_types": sorted(ALLOWED_IMAGE_CONTENT_TYPES),
                },
            },
        )

    suffix = ext if ext in ALLOWED_IMAGE_EXTENSIONS else ".jpg"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(file_bytes)
        temp_file_path = tmp.name

    logger.info(
        "OCR upload start request_id=%s filename=%s size_bytes=%s content_type=%s path=%s",
        request_id,
        original_filename,
        file_size,
        content_type,
        request.url.path,
    )

    try:
        result = await process_prescription_image(temp_file_path)

        if isinstance(result, dict) and result.get("error"):
            status_code = int(result.get("status_code", 500))
            detail_payload = {
                "message": str(result["error"]),
                "stage": result.get("stage", "ocr_pipeline"),
                "validation": result.get("validation"),
            }
            logger.warning(
                "OCR upload failed request_id=%s filename=%s size_bytes=%s "
                "content_type=%s status=%s stage=%s error=%r",
                request_id,
                original_filename,
                file_size,
                content_type,
                status_code,
                result.get("stage"),
                result["error"],
            )
            # For true server errors (5xx), raise HTTPException.
            # For OCR content failures (image unreadable / no medicines), return 200
            # with success=false so the Flutter client shows the real error message
            # instead of a generic "Server error (422)" snackbar.
            if status_code >= 500:
                raise HTTPException(status_code=status_code, detail=detail_payload)
            return {
                "filename": original_filename,
                "request_id": request_id,
                "success": False,
                "error": detail_payload["message"],
                "stage": detail_payload["stage"],
                "data": result,
            }

        duration_ms = int((time.perf_counter() - started_at) * 1000)
        logger.info(
            "OCR upload success request_id=%s duration_ms=%s filename=%s",
            request_id,
            duration_ms,
            original_filename,
        )

        return {
            "filename": original_filename,
            "request_id": request_id,
            "data": result
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("OCR upload server error request_id=%s", request_id)
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


class PasswordResetRequest(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)


class PasswordResetVerifyRequest(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)
    otp: str = Field(min_length=4, max_length=10)
    new_password: str = Field(min_length=6, max_length=128)


@app.post("/api/auth/password-reset/request")
def request_password_reset(req: PasswordResetRequest):
    try:
        service = _get_password_reset_service()
        result = service.request_password_reset_otp(req.identifier)
        return {"success": True, **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to process OTP request.")


@app.post("/api/auth/password-reset/verify")
def verify_password_reset(req: PasswordResetVerifyRequest):
    try:
        service = _get_password_reset_service()
        result = service.verify_otp_and_reset_password(
            identifier=req.identifier,
            otp=req.otp,
            new_password=req.new_password,
        )
        return {"success": True, **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to reset password.")


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
