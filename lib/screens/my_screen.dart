import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/start.dart';
import 'edit_profile_screen.dart';
import 'Call.dart';
import 'location_sms_sender.dart';


class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('WAYA', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? Locale('ar')
                  : Locale('en');
              context.setLocale(newLocale);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
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
        onHorizontalDragUpdate: (details) async {

          if (details.primaryDelta! > 10) {

            await sendEmergencyLocationSMS(context);
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
              const SizedBox(height: 30),
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
