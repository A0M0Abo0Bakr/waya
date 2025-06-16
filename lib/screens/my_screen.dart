import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/start.dart';
import 'edit_profile_screen.dart';
import 'Call.dart';
import 'package:waya/screens/location_sms_sender.dart';
import 'map_launcher.dart';

// استدعاء دالة الاتصال من sos.dart
import 'sos.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: Text('WAYA', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.black),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? Locale('ar')
                  : Locale('en');
              context.setLocale(newLocale);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            tooltip: 'edit_profile'.tr(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) async {
          if (details.primaryDelta != null) {
            if (details.primaryDelta! > 10) {
              // سحب من فوق لتحت (اصلي)
              await openGoogleMapsFromCurrentToSaved(context);
            } else if (details.primaryDelta! < -10) {
              // سحب من تحت لفوق => اتصال الطوارئ 122
              await callEmergencyNumber();
            }
          }
        },
        onHorizontalDragUpdate: (details) async {
          if (details.primaryDelta! > 10) {
            await sendHelpMessage(context);
          } else if (details.primaryDelta! < -10) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CallScreen()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Start(
                onPressed: () async {
                  await Future.delayed(Duration(seconds: 2));
                  return true;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}