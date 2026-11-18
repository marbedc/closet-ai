from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
from uuid import uuid4
from fastapi import File, UploadFile

app = FastAPI(title="ClosetAI API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {"status": "ok"}

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


@app.post("/wardrobe/upload")
async def upload_clothing_image(file: UploadFile = File(...)):
    item_id = str(uuid4())
    file_extension = Path(file.filename).suffix
    saved_filename = f"{item_id}{file_extension}"
    saved_path = UPLOAD_DIR / saved_filename

    contents = await file.read()
    saved_path.write_bytes(contents)

    return {
        "id": item_id,
        "filename": file.filename,
        "image_path": str(saved_path),
        "category": None,
        "color": None,
        "pattern": None,
        "formality": None,
    }