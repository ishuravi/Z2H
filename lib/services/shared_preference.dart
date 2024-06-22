import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    userInfo.forEach((key, value) async {
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    });
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userInfo = {};
    prefs.getKeys().forEach((key) {
      userInfo[key] = prefs.get(key);
    });
    return userInfo;
  }
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
  static Future<String?> getCustomerUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_customer_uid');
  }
}
