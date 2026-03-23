from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
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

# OCR Endpoint
@app.post("/api/ocr/upload")
async def upload_prescription(file: UploadFile = File(...)):
    """Endpoint to process prescription images using OCR."""
    temp_file_path = f"temp_{file.filename}"
    with open(temp_file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    result = process_prescription_image(temp_file_path)
    return {"filename": file.filename, "data": result}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
