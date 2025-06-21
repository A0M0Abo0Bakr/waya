import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _initTts() async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );

    await _cameraController?.initialize();
  }

  void _startLoop() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isProcessing) _captureAndSendImage();
    });
  }

  void _stopLoop() {
    _timer?.cancel();
  }

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    final ignoreBattery = await Permission.ignoreBatteryOptimizations.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("permissions_required_message".tr())),
      );
      return false;
    }
  }

  Future<void> _handlePress() async {
    if (!isRunning) {
      bool permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) return;

      bool result = await widget.onPressed();
      if (result) {
        try {
          await _initializeCamera();
          setState(() => isRunning = true);
          _startLoop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("camera_init_error".tr())),
          );
        }
      }
    } else {
      _stopLoop();
      _cameraController?.dispose();
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
      final filePath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      final file = File(filePath);
      await file.writeAsBytes(jpg);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.16:5000/predict'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      var response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _handleServerError();
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(respStr);
        List<dynamic> objects = data['objects'] ?? [];

        String speakText = objects.join(", ");
        await flutterTts.speak(speakText);
      } else {
        _handleServerError();
      }
    } catch (e) {
      _handleServerError();
    } finally {
      isProcessing = false;
    }
  }

  void _handleServerError() {
    final errorText = "Server is not responding. Please try again later.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorText)),
    );

    flutterTts.speak(errorText);

    _stopLoop();
    _cameraController?.dispose();
    _cameraController = null;

    setState(() {
      isRunning = false;
    });
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          backgroundColor: isRunning ? Colors.teal.shade200 : Colors.green.shade200,
        ),
        child: isRunning
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Text(
              "stop".tr(),
              style: const TextStyle(fontSize: 100, color: Colors.white),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 50,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        )
            : Text(
          "start".tr(),
          style: const TextStyle(fontSize: 100, color: Colors.white),
        ),
      ),
    );
  }
}
