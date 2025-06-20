# Face Recognition FastAPI Service

This is a FastAPI service that provides face recognition capabilities for the Rails time-tracker application.

## Features

- Face registration: Store face encodings for users
- Face recognition: Identify users from captured images
- RESTful API endpoints
- CORS support for web applications

## Setup Instructions

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Install System Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install python3-dev cmake build-essential
sudo apt-get install libdlib-dev libblas-dev liblapack-dev libjpeg-dev
```

### 3. Run the Service

```bash
python main.py
```

The service will start on `http://localhost:8000`

## API Endpoints

### POST /register_face
Register a new face encoding for a user.

**Request Body:**
```json
{
  "image": "base64_encoded_image_data",
  "user_id": 123
}
```

**Response:**
```json
{
  "success": true,
  "face_encoding": "base64_encoded_face_encoding"
}
```

### POST /recognize_face
Recognize a face and return the user ID.

**Request Body:**
```json
{
  "image": "base64_encoded_image_data"
}
```

**Response:**
```json
{
  "success": true,
  "user_id": 123,
  "confidence": 0.95
}
```

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "registered_faces": 5
}
```

## Configuration

### Environment Variables

- `FASTAPI_URL`: URL of the FastAPI service (default: http://localhost:8000)
- `FASTAPI_API_KEY`: API key for authentication (optional)

### CORS Configuration

Update the `allow_origins` list in `main.py` to include your Rails application URL:

```python
allow_origins=["http://localhost:3000", "http://your-rails-app.com"]
```

## Production Deployment

For production deployment:

1. Use a proper database instead of in-memory storage
2. Add authentication/authorization
3. Use HTTPS
4. Set up proper logging
5. Use a production ASGI server like Gunicorn

### Example with Gunicorn

```bash
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## Troubleshooting

### Common Issues

1. **ImportError: No module named 'dlib'**
   - Install system dependencies first
   - Try: `pip install dlib --no-cache-dir`

2. **Camera access issues**
   - Ensure browser has camera permissions
   - Check HTTPS requirement for camera access

3. **Face detection not working**
   - Ensure good lighting
   - Face should be clearly visible
   - Check image quality

## Security Notes

- This is a basic implementation for development
- For production, add proper authentication
- Consider rate limiting
- Implement proper error handling
- Use HTTPS in production 