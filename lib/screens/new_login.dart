import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'login_page.dart';

class NewLogin extends StatefulWidget {
  final String token; // Add token as a parameter

  const NewLogin(this.token, {Key? key}) : super(key: key);

  @override
  _NewLoginState createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _passwordVisible = false;
  String? _passwordError;

  void _validatePassword(String value) {
    // Password validation rules
    if (value.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters long.';
      });
      return;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        _passwordError = 'Password must contain at least 1 capital letter.';
      });
      return;
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      setState(() {
        _passwordError = 'Password must contain at least 1 lowercase letter.';
      });
      return;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      setState(() {
        _passwordError =
        'Password must contain at least 1 numeric character.';
      });
      return;
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() {
        _passwordError =
        'Password must contain at least 1 special character.';
      });
      return;
    }
    setState(() {
      _passwordError = null;
    });
  }

  Future<void> _updatePassword(BuildContext context) async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    Map<String, String> requestBody = {
      "current_password": currentPassword,
      "password": newPassword,
    };

    Map<String, String> headers = {
      "Authorization": "Token ${widget.token}",
      "Content-Type": "application/json",
    };

    http.Response response = await http.patch(
      Uri.parse(
          'https://z2h.in/api/z2h/user/update_password/'),
      headers: headers,
      body: json.encode(requestBody),
    );

    Map<String, dynamic> responseData = json.decode(response.body);

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Password Update',
      desc: responseData['message'],
      btnOkOnPress: () {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const LoginPage(); // Assuming UserLogin is your login page widget
          },
        ),
            (_) => false,
      );},
    ).show();
  }

  void _showSkipDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: 'Information',
      desc: 'You can change the password later under your setting option.',
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: Image.asset(
                        'assets/icons/client_logo.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                    // Current Password TextField
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // New Password TextField
                    TextField(
                      controller: _newPasswordController,
                      obscureText: !_passwordVisible,
                      onChanged: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        errorText: _passwordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Confirm Password TextField
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _passwordError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_newPasswordController.text ==
                            _confirmPasswordController.text) {
                          _updatePassword(context);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Error"),
                                content: const Text("Passwords do not match."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        WidgetStateProperty.all<Color>(const Color(0xFF5cc7e7)),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5), // Blue transparent background
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: TextButton(
                onPressed: () {
                  _showSkipDialog(context);
                },
                child: const Text(
                  'Do it later',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}