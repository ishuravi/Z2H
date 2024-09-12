import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zero2hero/screens/userProvider.dart';

import 'Notification provider.dart';
import 'screens/splash_screen.dart'; // Importing SplashScreen widget
import 'screens/signupDemo.dart';
import 'token_provider.dart'; // Import TokenProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TokenProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),

        // Add other providers as needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set initial route to SplashScreen
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignUpPageDemo1(),
      },
    );
  }
}

