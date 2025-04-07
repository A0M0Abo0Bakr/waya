import 'package:flutter/material.dart';
import 'button_one_sc.dart';
import 'button_two_sc.dart';
import 'button_three_sc.dart';


class MainScreen2 extends StatelessWidget {
  const MainScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WAYA'), // عنوان ثابت
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            ButtonOneSc(
              onPressed: () {
                // TODO: تنفيذ الأمر الأول هنا
              },
            ),
            SizedBox(height: 30),
            ButtonTwoSc(
              onPressed: () {
                // TODO: تنفيذ الأمر الثاني هنا
              },
            ),
            SizedBox(height: 30),
            ButtonThreeSc(
              onPressed: () {
                // TODO: تنفيذ الأمر الثاني هنا
              },
            ),
          ],
        ),
      ),
    );
  }
}
