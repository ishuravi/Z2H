import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../token_provider.dart';

class CustomerUIDProvider with ChangeNotifier {
  String _customerUID = '';

  String get customerUID => _customerUID;

  void setCustomerUID(String customerUID) {
    _customerUID = customerUID;
    notifyListeners();
  }

  Future<void> fetchAndSetCustomerUID(String token) async {
    final tokenProvider = Provider.of<TokenProvider>(context as BuildContext, listen: false);
    final token = tokenProvider.token;
    print('TokenFirstpage: $token');
    final response = await http.get(
      Uri.parse('http://154.61.75.25:8000/api/z2h/user/info/?accessed_from=mobile'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userCustomerUID = data['user_info']['user_customer_uid'];
      setCustomerUID(userCustomerUID);
    } else {
      throw Exception('Failed to load user info');
    }
  }
}
