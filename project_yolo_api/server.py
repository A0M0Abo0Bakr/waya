from flask import Flask, request, jsonify
from ultralytics import YOLO
import cv2
import numpy as np
from PIL import Image
import io

# تحميل الموديل المدرب مسبقًا
model = YOLO(r"C:\Users\ahmed\StudioProjects\waya\project_yolo_api\bestyolo.pt")

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    file = request.files['image']
    img_bytes = file.read()

    # تحويل الصورة إلى NumPy array
    image = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    img_array = np.array(image)

    # توقع باستخدام YOLO
    results = model.predict(source=img_array, conf=0.3, iou=0.45)

    detected_names = set()
    for result in results:
        cls_ids = result.boxes.cls.cpu().numpy().astype(int)
        names_map = result.names
        for cid in cls_ids:
            detected_names.add(names_map[cid])

    return jsonify({"objects": list(detected_names)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
