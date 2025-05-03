import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

class ButtonOneSc extends StatefulWidget {
  const ButtonOneSc({Key? key}) : super(key: key);

  @override
  State<ButtonOneSc> createState() => _ButtonOneScState();
}

class _ButtonOneScState extends State<ButtonOneSc> {
  bool _isDetecting = false;
  String _buttonText = "Start Detection";
  CameraController? _cameraController;
  Interpreter? _interpreter;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    Future<void> _loadModel() async {
      try {
        _interpreter = await Interpreter.fromAsset(
          'model/bestyolo_float32.tflite',
          options: InterpreterOptions()..threads = 4,
        );
        print("✅ Model loaded");

        // طباعة تفاصيل input
        final inputShape = _interpreter!.getInputTensor(0).shape;
        final inputType = _interpreter!.getInputTensor(0).type;
        print("📥 Input shape: $inputShape");
        print("📥 Input type: $inputType");

        // طباعة تفاصيل output
        final outputShape = _interpreter!.getOutputTensor(0).shape;
        final outputType = _interpreter!.getOutputTensor(0).type;
        print("📤 Output shape: $outputShape");
        print("📤 Output type: $outputType");

      } catch (e) {
        print("❌ Model load error: $e");
      }
    }

  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'model/bestyolo_float32.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      print("Model loaded.");
    } catch (e) {
      print("Model load error: $e");
    }
  }

  Future<void> _startDetection() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();

    setState(() {
      _isDetecting = true;
      _buttonText = "Stop Detection";
    });

    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isDetecting) return;

      try {
        // ناخد plane 0 فقط (Y channel)
        final plane = image.planes[0];
        final input = _preprocess(plane.bytes, image.width, image.height);

        final output = List.generate(1, (_) => List.filled(25200 * 6, 0.0)); // لازم نعرف شكل الإخراج الحقيقي

        _interpreter?.run(input, output);

        final classId = _parseOutput(output[0]);
        if (classId != null) {
          await flutterTts.speak("Detected class $classId");
        }
      } catch (e) {
        print("Detection error: $e");
      }
    });
  }

  Float32List _preprocess(Uint8List bytes, int width, int height) {
    // هنفترض دلوقتي أننا بنحول Y channel فقط إلى Float32 (رمادي)، ونكبر الصورة 416x416 ببساطة
    final size = 416;
    final resized = List<double>.filled(size * size * 3, 0);

    // عينة سريعة - نسخ أول البايتات فقط (مؤقتًا)
    final limit = math.min(bytes.length, size * size);
    for (int i = 0; i < limit; i++) {
      final pixel = bytes[i] / 255.0;
      resized[i * 3] = pixel;     // R
      resized[i * 3 + 1] = pixel; // G
      resized[i * 3 + 2] = pixel; // B
    }

    return Float32List.fromList(resized);
  }

  int? _parseOutput(List<double> output) {
    for (int i = 0; i < output.length; i += 6) {
      double confidence = output[i + 4];
      if (confidence > 0.5) {
        return output[i + 5].toInt(); // class_id
      }
    }
    return null;
  }

  Future<void> _stopDetection() async {
    try {
      await _cameraController?.stopImageStream();
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      print("Stop error: $e");
    }

    setState(() {
      _isDetecting = false;
      _buttonText = "Start Detection";
    });
  }

  void _toggleDetection() {
    if (_isDetecting) {
      _stopDetection();
    } else {
      _startDetection();
    }
  }

  @override
  void dispose() {
    _stopDetection();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 170,
      child: ElevatedButton(
        onPressed: _toggleDetection,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.green.shade700,
        ),
        child: Text(
          _buttonText,
          style: const TextStyle(fontSize: 50, color: Colors.white),
        ),
      ),
    );
  }
}
