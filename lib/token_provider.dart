import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String _token = ''; // Initialize with an empty string
  String _uid = '';


  String get token => _token;
  String get uid => _uid;

  void setToken(String token) {
    _token = token;
    notifyListeners(); // Notify listeners that the token has changed
  }
  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }
}
