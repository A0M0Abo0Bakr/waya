import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:easy_localization/easy_localization.dart';

final Telephony telephony = Telephony.instance;

Future<void> sendEmergencyLocationSMS(BuildContext context) async {
  try {
    // 🧭 الحصول على الموقع
    Position position = await _determinePosition();
    String address = "https://maps.google.com/?q=${position.latitude},${position.longitude}";

    // 📱 الحصول على الرقم من SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('phone_number');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showMessage(context, "no_phone_number".tr());
      return;
    }

    // 📝 نص الرسالة
    String emergencyText = tr("emergency_text");
    String message = "$emergencyText\n$address";

    // ✅ التأكد من الصلاحيات
    bool? permissionGranted = await telephony.requestSmsPermissions;
    if (permissionGranted != true) {
      _showMessage(context, tr("sms_permission_denied"));
      return;
    }

    // 🚀 إرسال الرسالة تلقائيًا
    await telephony.sendSms(
      to: phoneNumber,
      message: message,
    );

    _showMessage(context, tr("location_sent"));

  } catch (e) {
    _showMessage(context, "${tr("location_error")}$e");
  }
}

// تحديد الموقع
Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('location_not_enabled'.tr());

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) throw Exception('location_permission_denied'.tr());
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('location_permission_forever'.tr());
  }

  return await Geolocator.getCurrentPosition();
}

// عرض رسالة
void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
