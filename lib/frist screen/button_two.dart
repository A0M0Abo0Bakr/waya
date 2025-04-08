import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ButtonTwo extends StatelessWidget {
  final VoidCallback onPressed;
  const ButtonTwo({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250, // ارتفاع كبير
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.lightBlueAccent, // لون مختلف لو حابب
        ),
        child: Text(
          "botton2".tr(),
          style: TextStyle(fontSize: 50, color: Colors.white),
        ),
      ),
    );
  }
}
