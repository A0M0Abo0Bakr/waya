import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tflite_flutter/tflite_flutter.dart';

class ButtonOneSc extends StatefulWidget {
  const ButtonOneSc({super.key});

  @override
  State<ButtonOneSc> createState() => _ButtonOneScState();
}

class _ButtonOneScState extends State<ButtonOneSc> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  Interpreter? _interpreter;
  CameraController? _cameraController;
  bool _isListening = false;
  bool _isDetecting = false;
  bool _isCameraOn = false;

  List<String> labels = [
    'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train',
    'truck', 'boat', 'traffic light', 'fire hydrant', 'dog', 'cat',
    'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe',
    'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
    'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove',
    'skateboard', 'surfboard', 'tennis racket', 'bottle', 'wine glass',
    'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich',
    'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake',
    'chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv',
    'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave',
    'oven', 'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase',
    'scissors', 'teddy bear', 'hair drier', 'toothbrush'
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    await _speech.initialize();
    await _flutterTts.setLanguage("en-US");

    _interpreter = await Interpreter.fromAsset(
      'model/bestyolo_float32.tflite',
      options: InterpreterOptions()..threads = 4,
    );
    print("✅ Model loaded");
    _startListening();
  }

  Future<void> _startCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.low, enableAudio: true);
    await _cameraController!.initialize();
    print("📷 Camera initialized");

    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isDetecting) return;

      try {
        final input = _preprocessImage(image.planes[0].bytes, image.width, image.height);
        final output = List.generate(1, (_) => List.filled(25200 * 6, 0.0));

        _interpreter?.run(input, output);
        final classId = _parseOutput(output[0]);

        if (classId != null && classId < labels.length) {
          print("Detected: ${labels[classId]}");
          await _flutterTts.speak("Detected: ${labels[classId]}");
        }
      } catch (e) {
        print("❌ Error during model run: $e");
      }
    });
  }

  Future<void> _stopCamera() async {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    await _cameraController?.dispose();
    _cameraController = null;
    print("📴 Camera stopped");
  }

  Future<void> _toggleCamera() async {
    if (_isCameraOn) {
      await _stopCamera();
    } else {
      await _startCamera();
    }
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
  }

  Float32List _preprocessImage(Uint8List bytes, int width, int height) {
    final size = 416;
    final resized = List<double>.filled(size * size * 3, 0.0);
    final limit = math.min(bytes.length, size * size);
    for (int i = 0; i < limit; i++) {
      final pixel = bytes[i] / 255.0;
      resized[i * 3] = pixel;
      resized[i * 3 + 1] = pixel;
      resized[i * 3 + 2] = pixel;
    }
    return Float32List.fromList(resized);
  }

  int? _parseOutput(List<double> output) {
    for (int i = 0; i < output.length; i += 6) {
      double confidence = output[i + 4];
      if (confidence > 0.5) {
        return output[i + 5].toInt();
      }
    }
    return null;
  }

  Future<void> _startListening() async {
    _isListening = true;

    await _speech.listen(
      onResult: (result) async {
        if (result.finalResult) {
          final words = result.recognizedWords.toLowerCase();
          print("🎤 Heard: $words");

          if (words.contains("start")) {
            await _flutterTts.speak("Detection started");
            _isDetecting = true;
            if (!_isCameraOn) {
              await _toggleCamera();
            }
          } else {
            await _flutterTts.speak(words);
          }

          _isListening = false;
          await _speech.stop();
        }
      },
      localeId: 'en_US',
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isCameraOn && _cameraController != null && _cameraController!.value.isInitialized)
          SizedBox(
            height: 600,
            width: double.infinity,
            child: CameraPreview(_cameraController!),
          ),
        const SizedBox(
          width: double.infinity,
          height: 170, // Large height
        ),
        ElevatedButton(
          onPressed: _toggleCamera,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isCameraOn ? Colors.redAccent : Colors.blueGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _isCameraOn ? "Close Camera" : "Open Camera",
            style: const TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
