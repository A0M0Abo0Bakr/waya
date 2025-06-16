// sos.dart
import 'package:url_launcher/url_launcher.dart';

Future<void> callEmergencyNumber() async {
  final Uri callUri = Uri(scheme: 'tel', path: '122');
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    print('لا يمكن إجراء مكالمة الطوارئ');
  }
}
