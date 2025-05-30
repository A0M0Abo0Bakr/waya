from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
from PIL import Image
import torch
import numpy as np
import io
from gtts import gTTS
import uuid
import os

app = FastAPI()

model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)
os.makedirs("audio_temp", exist_ok=True)

@app.post("/detect/")
async def detect_and_speak(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    image = image.resize((256, 256))
    img = np.array(image)
    results = model(img)

    detected_classes = results.pandas().xyxy[0]['name'].unique().tolist()
    if not detected_classes:
        text = "لم يتم اكتشاف أي شيء"
    else:
        text = "، ".join(detected_classes)

    audio_path = f"audio_temp/{uuid.uuid4()}.mp3"
    tts = gTTS(text=text, lang='ar')
    tts.save(audio_path)

    return FileResponse(audio_path, media_type="audio/mpeg", filename="output.mp3")
