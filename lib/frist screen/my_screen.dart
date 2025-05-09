import 'package:flutter/material.dart';
import '../sconed screen/button_one_sc.dart';
import '../sconed screen/button_two_sc.dart';
import 'button_one.dart';
import 'button_two.dart';
import 'package:waya/sconed screen/my_screen_sc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:waya/edit_profile_screen.dart';
import 'package:waya/Call.dart';

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
        onHorizontalDragUpdate: (details) {

          if (details.primaryDelta! < -10) {
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
              ButtonOneSc(),
              const SizedBox(height: 30),
              ButtonTwoSc(onPressed: () {}),
              // SizedBox(height: 30),
              // ButtonOne(
              //   onLongPressStart: () {
              //
              //   },
              //   onLongPressEnd: () {
              //
              //   },
              // ),
              // SizedBox(height: 40),
              // ButtonTwo(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => MainScreen2()),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
