import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ButtonOne extends StatelessWidget {
  final VoidCallback onPressed;
  const ButtonOne({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          "button1".tr(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
