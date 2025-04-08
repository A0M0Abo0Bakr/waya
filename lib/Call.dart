import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
    _initiateCall();
  }

  // دالة للاتصال المباشر
  Future<void> _initiateCall() async {
    final phoneNumber = await _getPhoneNumber();  // استرجاع الرقم من SharedPreferences

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      // محاولة الاتصال بالرقم مباشرة
      if (await canLaunch(phoneUri.toString())) {
        await launch(phoneUri.toString());
      } else {
        // إذا لم يتمكن من إجراء الاتصال
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن إجراء الاتصال.')),
        );
      }
    } else {
      // إذا لم يتم العثور على الرقم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يوجد رقم مخصص للاتصال.')),
      );
    }
  }

  // دالة لتحميل الرقم من SharedPreferences
  Future<String?> _getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('familyPhone');  // استرجاع الرقم من SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اتصال مباشر'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: CircularProgressIndicator(),  // يمكنك تخصيص هذا المؤشر وفقًا لاحتياجاتك
      ),
    );
  }
}
