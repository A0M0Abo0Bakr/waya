import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:easy_localization/easy_localization.dart';

class Start extends StatefulWidget {
  final Future<bool> Function() onPressed;
  const Start({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  bool isRunning = false;
  CameraController? _cameraController;
  Timer? _timer;
  bool isProcessing = false;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );

    await _cameraController?.initialize();
  }

  Future<void> _initTts() async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  void _startLoop() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isProcessing) _captureAndSendImage();
    });
  }

  void _stopLoop() {
    _timer?.cancel();
  }

  Future<void> _handlePress() async {
    if (!isRunning) {
      bool result = await widget.onPressed();
      if (result) {
        await _initializeCamera(); // ← هنا
        setState(() => isRunning = true);
        _startLoop();
      }
    } else {
      _stopLoop();
      _cameraController?.dispose(); // ← مهم جدا نوقف الكاميرا
      _cameraController = null;
      setState(() => isRunning = false);
    }
  }


  Future<void> _captureAndSendImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      isProcessing = true;

      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();

      final decoded = img.decodeImage(bytes)!;
      final resized = img.copyResize(decoded, width: 256, height: 256);
      final jpg = img.encodeJpg(resized, quality: 70);

      final tempDir = await getTemporaryDirectory();
      final filePath = join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      final file = File(filePath);
      await file.writeAsBytes(jpg);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.21:5000/predict'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();

        final Map<String, dynamic> data = json.decode(respStr);
        List<dynamic> objects = data['objects'] ?? [];

        String speakText = objects.join(", ");

        await flutterTts.speak(speakText);
      }

    } catch (e) {
      print("Error: $e");
    } finally {
      isProcessing = false;
    }
  }

  @override
  void dispose() {
    _stopLoop();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 600,
      child: ElevatedButton(
        onPressed: _handlePress,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isRunning ? Colors.red : Colors.green.shade700,
        ),
        child: Text(
          isRunning ? "stop".tr() : "start".tr(),
          style: const TextStyle(fontSize: 50, color: Colors.white),
        ),
      ),
    );
  }
}
