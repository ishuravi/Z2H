import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zero2hero/screens/profile_demo1.dart';
import '../token_provider.dart';
 // Import your profile page here

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late Future<UserData> futureUserData;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  //final TextEditingController aadharNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController nameOfBankController = TextEditingController();
  final TextEditingController nameAsInBankController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController bankBranchController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUserData = fetchUserData();
  }

  Future<UserData> fetchUserData() async {
    const String apiUrl = 'https://z2h.in:8000/api/z2h/user/update_register_user/';
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userData = UserData.fromJson(data['data']);

      // Initialize controllers with the fetched data
      addressController.text = userData.address;
      maritalStatusController.text = userData.maritalStatus;
    //  aadharNumberController.text = userData.aadharNumber;
      cityController.text = userData.city;
      townController.text = userData.town;
      pinCodeController.text = userData.pinCode;
      nameOfBankController.text = userData.nameOfBank;
      nameAsInBankController.text = userData.nameAsInBank;
      ifscCodeController.text = userData.ifscCode;
      bankBranchController.text = userData.bankBranch;
      accountNumberController.text = userData.accountNumber;

      return userData;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> updateUserData() async {
    const String apiUrl = 'https://z2h.in:8000/api/z2h/user/update_register_user/';
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'address': addressController.text,
        'marital_status': maritalStatusController.text,
       // 'aadhar_number': aadharNumberController.text,
        'city': cityController.text,
        'town': townController.text,
        'pin_code': pinCodeController.text,
        'name_of_bank': nameOfBankController.text,
        'name_as_in_bank': nameAsInBankController.text,
        'ifsc_code': ifscCodeController.text,
        'bank_branch': bankBranchController.text,
        'account_number': accountNumberController.text,
        // Add other fields similarly if needed
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      // Navigate to the profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileDemo1()),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: FutureBuilder<UserData>(
        future: futureUserData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildTextField('Address', addressController),
                  _buildTextField('Marital Status', maritalStatusController),
                 // _buildTextField('Aadhar Number', aadharNumberController),
                  _buildTextField('City', cityController),
                  _buildTextField('Town', townController),
                  _buildTextField('Pin Code', pinCodeController),
                  _buildTextField('Name of Bank', nameOfBankController),
                  _buildTextField('Name as in Bank', nameAsInBankController),
                  _buildTextField('IFSC Code', ifscCodeController),
                  _buildTextField('Bank Branch', bankBranchController),
                  _buildTextField('Account Number', accountNumberController),
                  // Add other fields similarly
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateUserData,
                    child: Text('Update'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

class UserData {
  final String address;
  final String maritalStatus;
  final String? pan;
  final String aadharNumber;
  final int district;
  final String city;
  final String town;
  final String pinCode;
  final String nameOfBank;
  final String nameAsInBank;
  final String ifscCode;
  final String bankBranch;
  final String accountNumber;
  final String? alternateMobileNumber;
  final String? profilePhotoPath;

  UserData({
    required this.address,
    required this.maritalStatus,
    this.pan,
    required this.aadharNumber,
    required this.district,
    required this.city,
    required this.town,
    required this.pinCode,
    required this.nameOfBank,
    required this.nameAsInBank,
    required this.ifscCode,
    required this.bankBranch,
    required this.accountNumber,
    this.alternateMobileNumber,
    this.profilePhotoPath,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      address: json['address'],
      maritalStatus: json['marital_status'],
      pan: json['pan'],
      aadharNumber: json['aadhar_number'],
      district: json['district'],
      city: json['city'],
      town: json['town'],
      pinCode: json['pin_code'],
      nameOfBank: json['name_of_bank'],
      nameAsInBank: json['name_as_in_bank'],
      ifscCode: json['ifsc_code'],
      bankBranch: json['bank_branch'],
      accountNumber: json['account_number'],
      alternateMobileNumber: json['alternate_mobile_number'],
      profilePhotoPath: json['profile_photo_path'],
    );
  }
}
