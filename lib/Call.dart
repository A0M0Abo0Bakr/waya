import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  bool _launchedDialer = false;

  @override
  void initState() {
    super.initState();
    // نضيف الـ observer
    WidgetsBinding.instance.addObserver(this);
    // نستدعي الكول بعد أول فريم علشان ScaffoldMessenger يكون موجود
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiateCall();
    });
  }

  @override
  void dispose() {
    // نشيل الـ observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // نراقب حالة الـ Lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // لما ييجي من الخلفية (بعد ما يفتح Dialer) ونفسنا نقفل الشاشة دي
    if (state == AppLifecycleState.resumed && _launchedDialer) {
      Navigator.of(context).pop(); // يرجع للي قبلها
    }
  }

  Future<void> _initiateCall() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('familyPhone') ?? '';

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ما فيش رقم محفوظ للاتصال.')),
      );
      return;
    }

    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
      _launchedDialer = true;  // علّم إننا فتحنا الـ Dialer
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مش قادر أفتح تطبيق الاتصال.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
