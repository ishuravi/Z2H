import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero2hero/screens/signupDemo.dart';

import '../token_provider.dart';
import 'homepage.dart';
import 'new_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final Color customBorderColor = const Color(0xFF040D44);
  final Color customButtonColor = const Color(0xFF5cc7e7);
  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _mobileNumberEdited = true; // Track if mobile number field is edited
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showForgotPasswordDialog() {
    TextEditingController mobileController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0)), // Border radius
            //side: BorderSide(color: Colors.black, width: 2.0), // Border color and width
          ),
          backgroundColor: Colors.white,

          title: const Text("Forgot Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String mobileNumber = mobileController.text;
                String emailAddress = emailController.text;
                // Call forgot password API with mobileNumber and emailAddress
                _forgotPassword(mobileNumber, emailAddress);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _forgotPassword(String mobileNumber, String emailAddress) async {
    const String apiUrl = 'https://z2h.in/api/z2h/user/forgot_password/';
    final Uri uri = Uri.parse('$apiUrl?email_address=$emailAddress&mobile_number=$mobileNumber');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Password reset instructions sent successfully
      // Handle the response accordingly, maybe show a success message
    } else {
      // Failed to send password reset instructions
      // Handle the error, maybe show an error message
    }
  }


  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _mobileController.text = prefs.getString('mobileNumber') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }


  Future<void> _login() async {
    const String apiUrl = 'https://z2h.in/api/z2h/user/login/';
    final response = await http.post(Uri.parse(apiUrl), body: {
      'mobile_number': _mobileController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        String token = responseData['token'];
        bool isFirstLogin = responseData['is_first_login'] ?? false; // Default to false if not provided
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        Provider.of<TokenProvider>(context, listen: false).setToken(token);
        print("Login page token:$token");

        if (_rememberMe) {
          await prefs.setBool('rememberMe', true);
          await prefs.setString('mobileNumber', _mobileController.text);
          await prefs.setString('password', _passwordController.text);


        } else {
          await prefs.remove('rememberMe');
          await prefs.remove('mobileNumber');
          await prefs.remove('password');


        }

        if (isFirstLogin) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewLogin(token)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      }
    } else if (response.statusCode == 400) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'Warning',
        desc: 'Enter the valid credentials',
        btnOkText: 'OK',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Image.asset(
                        'assets/icons/client_logo.png',
                        fit: BoxFit.contain,
                        height: 200,
                        width: 200,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: customBorderColor),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                      errorText: _mobileController.text.isNotEmpty && _mobileNumberEdited &&
                          (_mobileController.text.length != 10 ||
                              !RegExp(r'^[0-9]+$').hasMatch(_mobileController.text))
                          ? 'Please enter a valid mobile number'
                          : null,
                    ),
                    onChanged: (_) {
                      setState(() {
                        _mobileNumberEdited = true;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      } else if (value.length != 10) {
                        return 'Mobile number must be 10 digits long';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Mobile number can only contain digits';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: customBorderColor),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(customButtonColor),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPageDemo1()),
                          );
                        },
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}
