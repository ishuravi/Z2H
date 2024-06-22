import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OTPVerificationDialog extends StatelessWidget {
  final TextEditingController otpController;
  final VoidCallback onResendOTP;
  final VoidCallback onSubmit;

  const OTPVerificationDialog({
    Key? key,
    required this.otpController,
    required this.onResendOTP,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter OTP"),
      content: TextField(
        controller: otpController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'OTP'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onResendOTP,
          child: const Text("Resend OTP"),
        ),
        TextButton(
          onPressed: onSubmit,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}