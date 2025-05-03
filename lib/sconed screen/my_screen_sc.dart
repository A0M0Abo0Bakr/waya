import 'package:flutter/material.dart';
import 'button_one_sc.dart';
import 'button_two_sc.dart';
import 'button_three_sc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:waya/Call.dart';

class MainScreen2 extends StatelessWidget {
  const MainScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('WAYA'), // عنوان ثابت
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.black),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en');
              context.setLocale(newLocale);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < -30) {
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
              const SizedBox(height: 20),
              ButtonOneSc(),
              const SizedBox(height: 30),
              ButtonTwoSc(onPressed: () {}),
              const SizedBox(height: 30),
              ButtonThreeSc(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
