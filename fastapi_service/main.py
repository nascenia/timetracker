from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import base64
import numpy as np
import cv2
import face_recognition
import json
from typing import Optional
import os

app = FastAPI(title="Face Recognition API", version="1.0.0")

# Enable CORS for Rails app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],  # Add your Rails app URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage for face encodings (in production, use a database)
face_encodings_db = {}

class FaceRegistrationRequest(BaseModel):
    image: str  # base64 encoded image
    user_id: int

class FaceRecognitionRequest(BaseModel):
    image: str  # base64 encoded image

class FaceRegistrationResponse(BaseModel):
    success: bool
    face_encoding: Optional[str] = None
    error: Optional[str] = None

class FaceRecognitionResponse(BaseModel):
    success: bool
    user_id: Optional[int] = None
    confidence: Optional[float] = None
    error: Optional[str] = None

def base64_to_image(base64_string: str):
    """Convert base64 string to OpenCV image"""
    try:
        # Remove data URL prefix if present
        if base64_string.startswith('data:image'):
            base64_string = base64_string.split(',')[1]
        
        # Decode base64
        image_data = base64.b64decode(base64_string)
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Convert BGR to RGB (face_recognition expects RGB)
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        return image_rgb
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image data: {str(e)}")

def image_to_base64(encoding: np.ndarray) -> str:
    """Convert numpy array to base64 string"""
    return base64.b64encode(encoding.tobytes()).decode('utf-8')

def base64_to_encoding(base64_string: str) -> np.ndarray:
    """Convert base64 string back to numpy array"""
    data = base64.b64decode(base64_string)
    return np.frombuffer(data, dtype=np.float64)

@app.post("/register_face", response_model=FaceRegistrationResponse)
async def register_face(request: FaceRegistrationRequest):
    """Register a new face encoding for a user"""
    try:
        # Convert base64 image to OpenCV format
        image = base64_to_image(request.image)
        
        # Detect faces in the image
        face_locations = face_recognition.face_locations(image)
        
        if not face_locations:
            return FaceRegistrationResponse(
                success=False,
                error="No face detected in the image"
            )
        
        if len(face_locations) > 1:
            return FaceRegistrationResponse(
                success=False,
                error="Multiple faces detected. Please use an image with only one face"
            )
        
        # Extract face encoding
        face_encodings = face_recognition.face_encodings(image, face_locations)
        face_encoding = face_encodings[0]
        
        # Store the encoding
        face_encodings_db[request.user_id] = image_to_base64(face_encoding)
        
        return FaceRegistrationResponse(
            success=True,
            face_encoding=image_to_base64(face_encoding)
        )
        
    except Exception as e:
        return FaceRegistrationResponse(
            success=False,
            error=f"Error processing face: {str(e)}"
        )

@app.post("/recognize_face", response_model=FaceRecognitionResponse)
async def recognize_face(request: FaceRecognitionRequest):
    """Recognize a face and return the user ID"""
    try:
        # Convert base64 image to OpenCV format
        image = base64_to_image(request.image)
        
        # Detect faces in the image
        face_locations = face_recognition.face_locations(image)
        
        if not face_locations:
            return FaceRecognitionResponse(
                success=False,
                error="No face detected in the image"
            )
        
        # Extract face encoding from the image
        face_encodings = face_recognition.face_encodings(image, face_locations)
        unknown_face_encoding = face_encodings[0]
        
        # Compare with stored encodings
        best_match = None
        best_confidence = 0.0
        
        for user_id, stored_encoding_b64 in face_encodings_db.items():
            stored_encoding = base64_to_encoding(stored_encoding_b64)
            
            # Compare faces
            matches = face_recognition.compare_faces([stored_encoding], unknown_face_encoding, tolerance=0.6)
            face_distances = face_recognition.face_distance([stored_encoding], unknown_face_encoding)
            
            if matches[0]:
                confidence = 1.0 - face_distances[0]
                if confidence > best_confidence:
                    best_confidence = confidence
                    best_match = user_id
        
        if best_match and best_confidence > 0.6:  # Confidence threshold
            return FaceRecognitionResponse(
                success=True,
                user_id=best_match,
                confidence=float(best_confidence)
            )
        else:
            return FaceRecognitionResponse(
                success=False,
                error="Face not recognized"
            )
        
    except Exception as e:
        return FaceRecognitionResponse(
            success=False,
            error=f"Error recognizing face: {str(e)}"
        )

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "registered_faces": len(face_encodings_db)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 