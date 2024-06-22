import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../token_provider.dart';


class ApiService {
  static const String apiUrl = 'http://154.61.75.25:8000/api/z2h/user/info/?accessed_from=mobile';

  static Future<Map<String, dynamic>> fetchUserInfo(BuildContext context) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user information');
    }
  }
}

