import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:zero2hero/screens/userProvider.dart';

import '../token_provider.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final String apiUrl = 'http://154.61.75.25:8000/api/z2h/user/info/?accessed_from=mobile';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'token $token'},

    );
    print("details page token: $token");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        Provider.of<UserProvider>(context, listen: false).setUserInfo(data['user_info']);
      }
    } else {
      throw Exception('Failed to load user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context).userInfo;

    return Scaffold(
      appBar: AppBar(
        title: Text("User Information"),
      ),
      body: userInfo.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Name: ${userInfo['name'] ?? ''}'),
            Text('Nominee Name: ${userInfo['nominee_name'] ?? ''}'),
            Text('Date of Birth: ${userInfo['date_of_birth'] ?? ''}'),
            Text('Marital Status: ${userInfo['marital_status'] ?? ''}'),
            Text('Gender: ${userInfo['gender'] ?? ''}'),
            Text('Aadhar Number: ${userInfo['aadhar_number'] ?? ''}'),
            Text('Mobile Number: ${userInfo['mobile_number'] ?? ''}'),
            Text('City: ${userInfo['city'] ?? ''}'),
            Text('Address: ${userInfo['address'] ?? ''}'),
            Text('Pin Code: ${userInfo['pin_code'] ?? ''}'),
            Text('Bank Name: ${userInfo['name_of_bank'] ?? ''}'),
            Text('IFSC Code: ${userInfo['ifsc_code'] ?? ''}'),
            Text('Account Number: ${userInfo['account_number'] ?? ''}'),
            Text('Email: ${userInfo['email_address'] ?? ''}'),
            Text('Customer uid: ${userInfo['user_customer_number'] ?? ''}'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
