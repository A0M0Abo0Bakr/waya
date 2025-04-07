import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ButtonTwoSc extends StatelessWidget {
  final VoidCallback onPressed;
  const ButtonTwoSc({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 170, // ارتفاع كبير
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.green.shade700, // لون مختلف لو حابب
        ),
        child: Text(
          "botton2".tr(),
          style: TextStyle(fontSize: 50),
        ),
      ),
    );
  }
}
