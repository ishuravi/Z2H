import 'package:flutter/material.dart';

import 'login_page.dart'; // Update this import as per your project structure

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState(); // Changed _SplashScreenState to SplashScreenState
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _imageOffsetAnimation;
  late Animation<Offset> _textOffsetAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _imageOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.5), // Start from off the screen on the right
      end: Offset.zero, // Move to the center of the screen
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _textOffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.5), // Start from off the screen on the left
      end: Offset.zero, // Move to the center of the screen
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0, // Zoom out to 2 times the original size
      end: 1.0, // Return to the original size
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });

    // Start the animation when the screen loads
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF69e2f4),
              Colors.white,
              Color(0xFF69e2f4),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: _imageOffsetAnimation,
                  child: Center(
                    child: Image.asset('assets/icons/client_logo.png'), // Your splash screen image
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add spacing between the image and text
              SlideTransition(
                position: _textOffsetAnimation,
                child: Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.red,
                          Colors.black,
                        ],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Elevate Your Life',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
