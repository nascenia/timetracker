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
async def register_face(image: UploadFile = File(...)):
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

'''
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
            #print(f'user_id: {user["user_id"]}, distance: {dist}')
            #distances.append({"user_id": user['user_id'], "distance": float(dist)})
            if dist < 0.3 and dist < min_dist:
                min_dist = dist
                matched_user = user
        response = {}
        if matched_user:
            response = {"success": True, "user_id": matched_user['user_id'], "confidence": 1 - min_dist}
        else:
            response = {"success": False, "error": "Face not recognized"}

        return JSONResponse(response)
    except Exception as e:
        return JSONResponse({"success": False, "error": str(e)})
'''
@app.post("/liveness_and_recognition")
async def liveness_and_recognition(
    frames: List[UploadFile] = File(...),
    users: str = Form(...),  # JSON string: [{user_id, face_encoding: [float, ...]}, ...]
    device_type: Optional[str] = Form('pc')
):
    # Debug: Print info about received frames
    print(f"[DEBUG] Received {len(frames)} frames.")

    #live_scores = []
    #antispoof_scores = []
    imgs = []
    total_score = 0.0
    pictures = 0
    for idx, frame in enumerate(frames):
        img_bytes = await frame.read()
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        np_img = np.array(img)
        
        try:
            faces = DeepFace.extract_faces(img_path=np_img, expand_percentage=30, anti_spoofing=True, enforce_detection=True)
            if faces and "is_real" in faces[0]:
                #is_live = faces[0]['is_real'] == True and faces[0]["antispoof_score"] > 0.95
                score = faces[0]["antispoof_score"]
                #print(f'score: {score}')
                total_score += score
                pictures += 1
            else:
                #is_live = False
                score = 0.0
                pictures += 1

            print(f"Frame {idx} score: {score}")
            #live_scores.append(1 if is_live else 0)
            #antispoof_scores.append(score)
            imgs.append(np_img)
        except Exception as e:
            print(f"error: {e=}")
            #live_scores.append(0)
            #antispoof_scores.append(0.0)
            #imgs.append(np_img)
            return JSONResponse({"success": False, "error": str(e)})
    #avg_score = float(np.mean(live_scores))
    #avg_antispoof = float(np.mean(antispoof_scores))
    avg_score = total_score / pictures
    is_live = avg_score >= 0.97  # You can tune this threshold
    print(f"AVG: {avg_score}")
    #print(f"antispoof avg: {avg_antispoof}")
    if not is_live or len(imgs) < 3:
        print("FAKE!!!")
        return JSONResponse({"success": False, "error": "Liveness check failed"})
    print("LIVE!!!")
    
    # 2. Face recognition (use 3rd frame, index 2)
    try:
        np_img = imgs[2]
        user_list = json.loads(users)
        embedding_objs = DeepFace.represent(np_img, model_name="ArcFace", enforce_detection=True)
        input_embedding = embedding_objs[0]['embedding']
        if isinstance(input_embedding, np.ndarray):
            input_embedding = input_embedding.tolist()
        min_dist = float('inf')
        matched_user = None
        for user in user_list:
            dist = cosine(input_embedding, user['face_encoding'])
            print(f"user: {user['user_id']} dist: {dist}")
            if dist < 0.4 and dist < min_dist:
                min_dist = dist
                matched_user = user
        if matched_user:
            print(f"MATCH!!!, mathed user: {matched_user['user_id']}")
            return JSONResponse({
                "success": True,
                "user_id": matched_user['user_id'],
            })
        else:
            print("NO MATCH")
            return JSONResponse({
                "success": False,
                "error": "Face not recognized"
            })
    except Exception as e:
        print(f"error in recognition: {e=}")
        return JSONResponse({"success": False, "error": str(e)})


def custom_analyze(self, img, facial_area):
    import torch
    import torch.nn.functional as F

    x, y, w, h = facial_area
    first_img = crop(img, (x, y, w, h), 2.7, 80, 80)
    second_img = crop(img, (x, y, w, h), 4, 80, 80)

    test_transform = Compose([ToTensor()])
    first_img = test_transform(first_img)
    first_img = first_img.unsqueeze(0).to(self.device)

    second_img = test_transform(second_img)
    second_img = second_img.unsqueeze(0).to(self.device)

    with torch.no_grad():
        first_result = self.first_model.forward(first_img)
        first_result = F.softmax(first_result).cpu().numpy()

        second_result = self.second_model.forward(second_img)
        second_result = F.softmax(second_result).cpu().numpy()

    first_score = first_result[0][1]
    second_score = second_result[0][1]
    print(f"1st: {first_score}    2nd: {second_score}")
    avg = (first_score + second_score) / 2

    is_real = True if avg >= 0.96 else False
    score = avg

    return is_real, score

# Patch the method globally
if not hasattr(Fasnet, "__original_analyze__"):
    Fasnet.__original_analyze__ = Fasnet.analyze
Fasnet.analyze = custom_analyze