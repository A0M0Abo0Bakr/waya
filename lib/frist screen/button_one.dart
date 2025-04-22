import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';

class ButtonOne extends StatefulWidget {
  const ButtonOne({Key? key, required Null Function() onLongPressStart, required Null Function() onLongPressEnd}) : super(key: key);

  @override
  _ButtonOneState createState() => _ButtonOneState();
}

class _ButtonOneState extends State<ButtonOne> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    // تهيئة مكتبات الصوت
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _audioPlayer = AudioPlayer();
    _initializeSpeech();
    _flutterTts.setLanguage('en-US');
  }

  // تهيئة مكتبة التعرف على الصوت
  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  // بدء التسجيل عند الضغط المطوّل
  void _onLongPressStart(LongPressStartDetails details) async {
    // صوت بداية التسجيل
    await _audioPlayer.play(AssetSource('sound/beep.mp3'));

    // ابدأ الاستماع (push-to-talk)
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: _onSpeechResult,
      localeId: 'en_US',
       // offline mode
    );
  }

  // إيقاف التسجيل عند انتهاء الضغط
  void _onLongPressEnd(LongPressEndDetails details) async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  // عند استلام نتيجة التعرف على الصوت
  void _onSpeechResult(stt.SpeechRecognitionResult result) async {
    if (result.finalResult) {
      _lastWords = result.recognizedWords.toLowerCase();

      // إذا قال "start"، يرد "done"
      if (_lastWords.contains('start')) {
        await _flutterTts.speak('done');
      } else {
        // لو مش "start" يردد الكلام زي ما هو
        await _flutterTts.speak(_lastWords);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: _isListening ? Colors.redAccent : Colors.blueGrey,
          ),
          child: Text(
            _isListening ? 'Listening...' : 'botton1'.tr(),
            style: const TextStyle(fontSize: 50, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
