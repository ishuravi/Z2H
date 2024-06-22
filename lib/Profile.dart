import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zero2hero/token_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserInfo> futureUserInfo;

  @override
  void initState() {
    super.initState();
    futureUserInfo = fetchUserInfo();
  }

  Future<UserInfo> fetchUserInfo() async {

    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    print('TokenFirstpage: $token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('http://154.61.75.25:8000/api/z2h/user/info/?accessed_from=mobile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body)['user_info']);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserInfo>(
        future: futureUserInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF32d0fc),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(100.0),
                      bottomLeft: Radius.circular(100.0),
                    ),
                  ),
                  height: 200.0,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      snapshot.data!.name,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                 Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(50, 150, 50, 20),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.amber,
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                 Padding(
                  padding: EdgeInsets.fromLTRB(230, 270, 50, 20),
                  child: Icon(
                    Icons.list,
                    color: Colors.black,
                    size: 50,
                  ),
                ),

              ],

            );

          } else {
            return const Center(child: Text('No data available'));
          }
        },

      ),
    );
  }
}

class UserInfo {
  final String name;
  final String email;
  final String mobileNumber;
  final String DateofBirth;
  final String aatharNumber;
  final String NomineeName;
  final String maritalStatus;
  final String gender;
  final String town;
  final String city;
  final String state;
  final String address;
  final String pincode;
  final String nameOfBank;
  final String nameAsBank;
  final String ifscCode;
  final String bankBranch;
  final String accountNumber;
 // final String district;



  UserInfo({
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.DateofBirth,
    required this. aatharNumber,
    required this.gender,
    required this.city,
    required this.NomineeName,
    required this.maritalStatus,
    required this.town,
    required this.state,
  required this.address,
  required this.pincode,
  required this.nameOfBank,
  required this.nameAsBank,
  required this.ifscCode,
  required this.bankBranch,
  required this.accountNumber,
  //required this.district
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
      email: json['email_address'],
      mobileNumber: json['mobile_number'],
      DateofBirth: json['date_of_birth'],
      aatharNumber: json['aadhar_number'],
      NomineeName: json['nominee_name'],
      maritalStatus: json['marital_status'],
      town: json['town'],
      gender: json['gender'],
      city: json['city'],
      state: json['state'],
      address: json['address'],
      pincode: json['pin_code'],
      nameOfBank: json['name_of_bank'],
      nameAsBank: json['name_as_in_bank'],
      ifscCode: json['ifsc_code'],
      bankBranch: json['bank_branch'],
      accountNumber: json['account_number'],
      //district: json['Madurai']

    );
  }
}
