import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> sendHelpMessage(BuildContext context) async {
  try {
    // 📍 تحديد الموقع الحالي
    Position position = await Geolocator.getCurrentPosition();

    // 📱 قراءة رقم الطوارئ من SharedPreferences باستخدام المفتاح الصحيح
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('familyPhone');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showMessage(context, tr("no_phone_number"));
      return;
    }

    // 📝 تجهيز نص الرسالة باستخدام الترجمة
    String message = Uri.encodeComponent(
      "${tr("emergency_text")}\nhttps://maps.google.com/?q=${position.latitude},${position.longitude}",
    );

    // 📤 فتح تطبيق الرسائل مع تعبئة الرقم والرسالة
    final Uri smsUri = Uri.parse("sms:$phoneNumber?body=$message");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      _showMessage(context, tr("sms_app_cannot_open"));
    }

  } catch (e) {
    _showMessage(context, "${tr("location_error")} $e");
  }
}

void _showMessage(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
}
