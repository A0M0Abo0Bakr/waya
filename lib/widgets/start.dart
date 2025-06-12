import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  final Future<bool> Function() onPressed;
  const Start({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  bool isSuccess = false;

  Future<void> _handlePress() async {
    bool result = await widget.onPressed();
    if (result) {
      setState(() {
        isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 600,
      child: ElevatedButton(
        onPressed: _handlePress,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isSuccess ? Colors.grey : Colors.green.shade700,
        ),
        child: Text(
          "start".tr(),
          style: TextStyle(fontSize: 50, color: Colors.white),
        ),
      ),
    );
  }
}
