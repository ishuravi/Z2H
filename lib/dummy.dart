import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone_email_auth/phone_email_auth.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String? userAccessToken;
  String? jwtUserToken;
  bool hasUserLogin = false;
  PhoneEmailUserModel? phoneEmailUserModel;

  @override
  void initState() {
    super.initState();
    PhoneEmail.initializeApp(clientId: '16995501200085907886');
  }

  void getUserInfo() {
    if (userAccessToken != null) {
      PhoneEmail.getUserInfo(
        accessToken: userAccessToken!,
        clientId: '16995501200085907886',
        onSuccess: (userData) {
          setState(() {
            phoneEmailUserModel = userData;
            var countryCode = phoneEmailUserModel?.countryCode;
            var phoneNumber = phoneEmailUserModel?.phoneNumber;
            // Use this verified phone number to register user and create your session
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhoneLoginButton(
              borderRadius: 10,
              buttonColor: Colors.teal,
              label: 'Verify OTP',
              onSuccess: (String accessToken, String jwtToken) {
                if (accessToken.isNotEmpty) {
                  setState(() {
                    userAccessToken = accessToken;
                    jwtUserToken = jwtToken;
                    hasUserLogin = true;
                  });
                  getUserInfo();
                }
              },
            ),
            if (hasUserLogin) ...[
              Text('User logged in successfully'),
              if (phoneEmailUserModel != null)
                Text('Phone Number: ${phoneEmailUserModel!.phoneNumber}')
            ]
          ],
        ),
      ),
    );
  }
}
