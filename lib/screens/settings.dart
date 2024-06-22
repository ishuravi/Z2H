import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zero2hero/screens/new_login.dart';
import '../token_provider.dart'; // Import TokenProvider

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFDCFFFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(250.0),
                ),
              ),
              height: 250.0,
              width: 500.0,
              child: Center(
                child: Image.asset(
                  'assets/icons/client_logo.png',
                  fit: BoxFit.contain,
                  height: 200,
                  width: 200,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: ElevatedButton(
              onPressed: () {
                String token = Provider.of<TokenProvider>(context, listen: false).token;
                if (token.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewLogin(token)),
                  );
                } else {
                  // Handle case when token is not available
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFaaffff),
              ),
              child: const Text(
                'Update password',
                style: TextStyle(
                  color: Color(0xFF007dfe),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
