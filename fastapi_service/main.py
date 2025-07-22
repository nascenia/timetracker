import numpy as np
from fastapi import FastAPI, Request, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from deepface import DeepFace
from scipy.spatial.distance import cosine
import io
from PIL import Image
import json
from fastapi.responses import JSONResponse
from deepface.models.spoofing.FasNet import Fasnet, crop, Compose, ToTensor
from fastapi import FastAPI, UploadFile, File, Form, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from db import get_db  # as in previous best-practice answer
from crud import create_or_update_embedding  # as in previous best-practice answer
import asyncio
from db import AsyncSessionLocal  # Make sure async_session is your sessionmaker
import time
import logging
import sqlite3
from datetime import datetime
import ipaddress

# Custom SQLite logging handler
class SQLiteHandler(logging.Handler):
    def __init__(self, db_path):
        logging.Handler.__init__(self)
        self.db_path = db_path
        self._ensure_table()

    def _ensure_table(self):
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        c.execute('''
            CREATE TABLE IF NOT EXISTS fastapi_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                level TEXT,
                message TEXT
            )
        ''')
        conn.commit()
        conn.close()

    def emit(self, record):
        try:
            msg = self.format(record)
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            c.execute(
                "INSERT INTO fastapi_logs (level, message) VALUES (?, ?)",
                (record.levelname, msg)
            )
            conn.commit()
            conn.close()
        except Exception:
            self.handleError(record)

# Set up logger
logger = logging.getLogger("fastapi_service")
logger.setLevel(logging.INFO)
file_handler = logging.FileHandler("fastapi_service.log")
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

# Use the correct path for the SQLite DB (same directory as main.py)
import os
db_path = os.path.join(os.path.dirname(__file__), "face_db.sqlite3")
sqlite_handler = SQLiteHandler(db_path)
sqlite_handler.setLevel(logging.INFO)
sqlite_handler.setFormatter(formatter)
logger.addHandler(sqlite_handler)

# Global cache for user embeddings
user_embeddings_cache = {"pc": {}, "mb": {}}

'''
# Define model globals here
arcface_model = None
anti_spoofing_model = None
'''

async def load_embeddings_from_db(db, device_type):
    from models import UserEmbedding
    from sqlalchemy.future import select
    if device_type == "mb":
        result = await db.execute(select(UserEmbedding.user_id, UserEmbedding.embedding_mb).where(UserEmbedding.embedding_mb != None))
    else:
        result = await db.execute(select(UserEmbedding.user_id, UserEmbedding.embedding_pc).where(UserEmbedding.embedding_pc != None))
    user_embeddings_cache[device_type] = {row[0]: row[1] for row in result.fetchall()}

app = FastAPI()

# Allow CORS for local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=[""],
    #allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class RegisterRequest(BaseModel):
    image: str
    user_id: int

class RecognizeUser(BaseModel):
    user_id: int
    face_encoding: List[float]

class RecognizeRequest(BaseModel):
    image: str
    users: List[RecognizeUser]
    debug: Optional[bool] = False


import os
os.environ["CUDA_VISIBLE_DEVICES"] = ""

@app.on_event("startup")
async def startup_event():
    async with AsyncSessionLocal() as db:
        await load_embeddings_from_db(db, "pc")
        await load_embeddings_from_db(db, "mb")
    #load_models()

@app.post("/register_face")
async def register_face(
    image: UploadFile = File(...),
    user_id: int = Form(...),
    device_type: str = Form(...),  # 'pc' or 'mb'
    db: AsyncSession = Depends(get_db)
):
    logger.info(f"[register_face] Called for user_id={user_id}, device_type={device_type}")
    try:
        img_bytes = await image.read()
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        np_img = np.array(img)
        logger.info(f"[register_face] Creating embedding for user_id={user_id}")
        embedding_objs = await asyncio.to_thread(
            DeepFace.represent,
            img_path=np_img,
            model_name="ArcFace",
            enforce_detection=True,
            detector_backend="retinaface"
        )
        if not embedding_objs or 'embedding' not in embedding_objs[0]:
            logger.error(f"[register_face] No face detected for user_id={user_id}\n\n\n\n\n")
            return JSONResponse({"success": False, "error": "No face detected"})
        embedding = embedding_objs[0]['embedding']
        if isinstance(embedding, np.ndarray):
            embedding = embedding.tolist()
        logger.info(f"[register_face] Embedding created for user_id={user_id}")
        # Save embedding in DB
        await create_or_update_embedding(db, user_id, embedding, device_type)
        logger.info(f"[register_face] Embedding saved to DB for user_id={user_id}, device_type={device_type}")
        # Update cache for this user
        user_embeddings_cache[device_type][user_id] = embedding
        logger.info(f"[register_face] Embedding cached for user_id={user_id}, device_type={device_type}")
        logger.info(f"[register_face] Face registration success for user_id={user_id}\n\n\n\n\n")
        return JSONResponse({"success": True, "message": "Face registered successfully"})
    except Exception as e:
        logger.error(f"[register_face] Exception for user_id={user_id}: {e}\n\n\n\n\n")
        return JSONResponse({"success": False, "error": str(e)})



@app.post("/liveness_and_recognition")
async def liveness_and_recognition(
    frames: List[UploadFile] = File(...),
    device_type: str = Form(...),
    #db: AsyncSession = Depends(get_db)
):
    logger.info(f"[liveness_and_recognition] Called from {device_type}, received {len(frames)} frames")
    t0 = time.time()
    frame_bytes_list = [await frame.read() for frame in frames]

    async def liveness_task():
        logger.info(f"[liveness_and_recognition] Liveness detection started")
        total_score = 0.0
        pictures = 0
        for idx, img_bytes in enumerate(frame_bytes_list):
            img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
            np_img = np.array(img)
            try:
                faces = await asyncio.to_thread(
                    DeepFace.extract_faces,
                    img_path=np_img,
                    expand_percentage=30,
                    anti_spoofing=True
                )
                if faces and "is_real" in faces[0]:
                    score = faces[0]["antispoof_score"]
                    total_score += score
                    pictures += 1
                else:
                    score = 0.0
                    pictures += 1
                logger.info(f"[liveness_and_recognition] Frame {idx} liveness score: {score}")
            except Exception as e:
                logger.error(f"[liveness_and_recognition] Liveness detection error on frame {idx}: {e}")
                return {"success": False, "error": "Face couldn't be detected"}
        avg_score = total_score / pictures
        is_live = avg_score >= 0.97
        logger.info(f"[liveness_and_recognition] Liveness avg score: {avg_score}, result: {'LIVE' if is_live else 'FAKE'}")
        if not is_live:
            logger.warning(f"[liveness_and_recognition] Liveness check failed")
            return {"success": False, "error": "Liveness check failed"}
        logger.info(f"[liveness_and_recognition] Liveness check passed")
        return {"success": True}

    async def recognition_task():
        logger.info(f"[liveness_and_recognition] Recognition started")
        img_bytes = frame_bytes_list[2]
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        np_img = np.array(img)
        embedding_objs = await asyncio.to_thread(
            DeepFace.represent,
            img_path=np_img,
            model_name="ArcFace",
            enforce_detection=True,
            detector_backend="retinaface"
        )
        if not embedding_objs or 'embedding' not in embedding_objs[0]:
            logger.error(f"[liveness_and_recognition] No face detected in recognition frame")
            return {"success": False, "error": "No face detected"}
        input_embedding = embedding_objs[0]['embedding']
        logger.info(f"[liveness_and_recognition] recognition image's embedding generated")
        if isinstance(input_embedding, np.ndarray):
            input_embedding = input_embedding.tolist()
        user_embeddings = user_embeddings_cache[device_type].items()
        logger.info(f"[liveness_and_recognition] Fetched all users' image embedding from cache")
        min_dist = float('inf')
        matched_user_id = None
        for user_id, embedding in user_embeddings:
            dist = cosine(input_embedding, embedding)
            logger.info(f"[liveness_and_recognition] Recognition: user {user_id} dist {dist}")
            if dist < 0.4 and dist < min_dist:
                min_dist = dist
                matched_user_id = user_id
        if matched_user_id is not None:
            logger.info(f"[liveness_and_recognition] Recognition success: user_id={matched_user_id} confidence={1-min_dist}")
            return {"success": True, "user_id": matched_user_id, "confidence": 1 - min_dist}
        else:
            logger.warning(f"[liveness_and_recognition] Recognition failed: no match")
            return {"success": False, "error": "Face not recognized"}

    # Run both tasks as asyncio Tasks and cancel the other if one fails
    liveness_future = asyncio.create_task(liveness_task())
    recognition_future = asyncio.create_task(recognition_task())
    tasks = {liveness_future, recognition_future}
    results = {}
    t2 = time.time()
    try:
        while tasks:
            done, tasks = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
            for finished in done:
                result = await finished
                if finished is liveness_future:
                    results['liveness'] = result
                    if not result.get("success"):
                        logger.warning("[liveness_and_recognition] Liveness failed, cancelling recognition")
                        recognition_future.cancel()
                        t3 = time.time(); logger.info(f"[liveness_and_recognition] Time taken for Liveness+Recognition: {t3-t2:.3f}s (fail)\n\n\n\n\n")
                        return JSONResponse(result)
                elif finished is recognition_future:
                    results['recognition'] = result
                    if not result.get("success"):
                        logger.warning("[liveness_and_recognition] Recognition failed, cancelling liveness")
                        liveness_future.cancel()
                        t3 = time.time(); logger.info(f"[liveness_and_recognition] Time taken for Liveness+Recognition: {t3-t2:.3f}s (fail)\n\n\n\n\n")
                        return JSONResponse(result)
        # If both succeeded
        if results.get('liveness', {}).get("success") and results.get('recognition', {}).get("success"):
            recognition_status = results['recognition']
            logger.info(f"[liveness_and_recognition] Success: user_id={recognition_status['user_id']}")
            t3 = time.time(); logger.info(f"[liveness_and_recognition] Time taken for Liveness+Recognition: {t3-t2:.3f}s (success)\n\n\n\n\n")
            return JSONResponse({"success": True, "user_id": recognition_status["user_id"], "confidence": recognition_status.get("confidence")})
        logger.error("[liveness_and_recognition] Unexpected state: both tasks finished but not both succeeded\n\n\n\n\n")
        return JSONResponse({"success": False, "error": "Unknown error"})
    except asyncio.CancelledError:
        logger.warning("[liveness_and_recognition] Task cancelled due to other failure\n\n\n\n\n")
        return JSONResponse({"success": False, "error": "Cancelled due to other failure"})



'''
def load_models():
    global arcface_model, anti_spoofing_model
    if arcface_model is None:
        arcface_model = DeepFace.build_model("ArcFace")
    if anti_spoofing_model is None:
        from deepface.models.spoofing.FasNet import Fasnet
        anti_spoofing_model = Fasnet()
'''

def custom_analyze(self, img, facial_area):
    import torch
    import torch.nn.functional as F

    x, y, w, h = facial_area
    first_img = crop(img, (x, y, w, h), 2.7, 80, 80)
    #second_img = crop(img, (x, y, w, h), 4, 80, 80)

    test_transform = Compose([ToTensor()])
    first_img = test_transform(first_img)
    first_img = first_img.unsqueeze(0).to(self.device)

    #second_img = test_transform(second_img)
    #second_img = second_img.unsqueeze(0).to(self.device)

    with torch.no_grad():
        first_result = self.first_model.forward(first_img)
        first_result = F.softmax(first_result).cpu().numpy()

        #second_result = self.second_model.forward(second_img)
        #second_result = F.softmax(second_result).cpu().numpy()

    first_score = first_result[0][1]
    #second_score = second_result[0][1]
    #print(f"1st: {first_score}")
    #avg = (first_score + second_score) / 2
    avg = first_score
    is_real = True if avg >= 0.96 else False
    score = avg

    return is_real, score

# Patch the method globally
if not hasattr(Fasnet, "__original_analyze__"):
    Fasnet.__original_analyze__ = Fasnet.analyze
Fasnet.analyze = custom_analyze