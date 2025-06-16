import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> openGoogleMapsFromCurrentToSaved(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString('locationUrl');

  if (savedUrl == null || savedUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("location_not_found".tr())),
    );
    return;
  }

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final currentLat = position.latitude;
    final currentLng = position.longitude;

    final finalUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLng&destination=$savedUrl&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(finalUrl))) {
      await launchUrl(Uri.parse(finalUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("cannot_launch_maps".tr())),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("location_error".tr())),
    );
  }
}
