import base64
import numpy as np
from fastapi import FastAPI, Request, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from deepface import DeepFace
from scipy.spatial.distance import cosine
import cv2
import io
from PIL import Image
import json
from fastapi.responses import JSONResponse

app = FastAPI()

# Allow CORS for local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
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


@app.post("/register_face")
async def register_face(image: UploadFile = File(...), user_id: int = Form(...)):
    try:
        img_bytes = await image.read()
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        np_img = np.array(img)
        embedding_objs = DeepFace.represent(img_path=np_img, model_name="ArcFace", enforce_detection=True, detector_backend="retinaface")
        if not embedding_objs or 'embedding' not in embedding_objs[0]:
            return JSONResponse({"success": False, "error": "No face detected"})
        embedding = embedding_objs[0]['embedding']
        if isinstance(embedding, np.ndarray):
            embedding = embedding.tolist()
        return JSONResponse({"success": True, "face_encoding": embedding})
    except Exception as e:
        return JSONResponse({"success": False, "error": str(e)})

@app.post("/recognize_face")
async def recognize_face(image: UploadFile = File(...), users: str = Form(...), debug: bool = Form(False)):
    try:
        img_bytes = await image.read()
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        np_img = np.array(img)
        user_list = json.loads(users)
        min_dist = float('inf')
        matched_user = None
        distances = []
        input_objs = DeepFace.represent(img_path=np_img, model_name="ArcFace", enforce_detection=True, detector_backend="retinaface")
        if not input_objs or 'embedding' not in input_objs[0]:
            return JSONResponse({"success": False, "error": "No face detected"})
        input_embedding = input_objs[0]['embedding']
        if isinstance(input_embedding, np.ndarray):
            input_embedding = input_embedding.tolist()
        for user in user_list:
            dist = cosine(input_embedding, user['face_encoding'])
            #distances.append({"user_id": user['user_id'], "distance": float(dist)})
            if dist < 0.2 and dist < min_dist:
                min_dist = dist
                matched_user = user
        response = {}
        if matched_user:
            response = {"success": True, "user_id": matched_user['user_id'], "confidence": 1 - min_dist}
        else:
            response = {"success": False, "error": "Face not recognized"}
        if debug:
            response["debug"] = {
                "input_embedding": input_embedding,
                "distances": distances
            }
        return JSONResponse(response)
    except Exception as e:
        return JSONResponse({"success": False, "error": str(e)})