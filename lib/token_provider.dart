import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String _token = ''; // Initialize with an empty string

  String get token => _token;

  void setToken(String token) {
    _token = token;
    notifyListeners(); // Notify listeners that the token has changed
  }
}
