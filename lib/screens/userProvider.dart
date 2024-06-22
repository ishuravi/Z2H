import 'package:flutter/material.dart';

import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> _userInfo = {};

  Map<String, dynamic> get userInfo => _userInfo;

  void setUserInfo(Map<String, dynamic> userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  Future<void> fetchAndSetUserInfo(BuildContext context) async {
    try {
      final userInfo = await ApiService.fetchUserInfo(context);
      setUserInfo(userInfo['user_info']);
    } catch (e) {
      print('Failed to fetch and set user info: $e');
    }
  }
}
