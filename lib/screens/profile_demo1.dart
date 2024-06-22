import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:zero2hero/screens/userProvider.dart';
import 'edit_profile.dart';
import '../token_provider.dart';

class ProfileDemo1 extends StatefulWidget {
  const ProfileDemo1({super.key});

  @override
  State<ProfileDemo1> createState() => _ProfileDemoState();
}

class _ProfileDemoState extends State<ProfileDemo1> {
  File? _image;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchAndSetUserInfo(context);
  }

  Future<void> _showReferrerDetailsDialog() async {
    final userInfo = Provider.of<UserProvider>(context, listen: false).userInfo;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Referrer Details', style: TextStyle(color: Colors.blue[900])),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UID:  ${userInfo['referrer_uid'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Text('Name:  ${userInfo['referrer_name'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Text('City:  ${userInfo['referrer_city'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Text('Town:  ${userInfo['referrer_town'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Text('Mobile:  ${userInfo['referrer_mobile_number'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReferralIdDialog() async {
    final userInfo = Provider.of<UserProvider>(context, listen: false).userInfo;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your Referral ID', style: TextStyle(color: Colors.blue[900])),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${userInfo['user_customer_number'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: userInfo['user_customer_uid'] ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Referral ID copied to clipboard')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://154.61.75.25:8000/api/z2h/utils/image_upload/'),
    );
    request.headers['Authorization'] = 'Token $token';
    request.fields['upload_type'] = 'profile_image';
    request.files.add(await http.MultipartFile.fromPath('file_name', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      final imagePath = jsonResponse['image_upload_path'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );

      // Now send the imagePath to the update_register_user endpoint
      await _updateUserProfile(imagePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<void> _updateUserProfile(String imagePath) async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;

    final response = await http.post(
      Uri.parse('http://154.61.75.25:8000/api/z2h/user/update_register_user/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'profile_photo_path': imagePath,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context).userInfo;
    bool isLoading = userInfo.isEmpty;

    String? profilePhotoPath = userInfo['profile_photo_path'] as String?;
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF32d0fc),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(0.0),
                bottomLeft: Radius.circular(0.0),
              ),
            ),
            height: 250.0,
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 50, 50, 20),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.amber,
                      backgroundImage: profilePhotoPath != null ? NetworkImage(profilePhotoPath) : null,
                      child: profilePhotoPath == null
                          ? Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.blue[900],
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.camera_alt,
                            size: 25,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue[900]),
                        SizedBox(width: 10),
                        Text(
                          '${userInfo['name']}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        onSelected: (value) {
                          switch (value) {
                            case 'edit_profile':
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfile()),
                              );
                              break;
                            case 'referral_details':
                              _showReferrerDetailsDialog();
                              break;
                            case 'your_refer_id':
                              _showReferralIdDialog();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit_profile',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit Profile'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'referral_details',
                            child: ListTile(
                              leading: Icon(Icons.person_add),
                              title: Text('Referral Details'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'your_refer_id',
                            child: ListTile(
                              leading: Icon(Icons.confirmation_number),
                              title: Text('Your Refer ID'),
                            ),
                          ),
                        ],
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.more_horiz,
                            size: 25,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.blue[900]),
                        SizedBox(width: 10),
                        Text(
                          '${userInfo['email_address']}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.blue[900]),
                        SizedBox(width: 8),
                        Text(
                          '${userInfo['mobile_number']}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                buildUserDetailTile('Gender', userInfo['gender']),
                buildUserDetailTile('Date of Birth', userInfo['date_of_birth']),
                buildUserDetailTile('Marital Status', userInfo['marital_status']),
                buildUserDetailTile('Address', userInfo['address']),
                buildUserDetailTile('State', userInfo['state']),
                buildUserDetailTile('District', userInfo['district']),
                buildUserDetailTile('City', userInfo['city']),
                buildUserDetailTile('Town', userInfo['town']),
                buildUserDetailTile('Pincode', userInfo['pin_code']),
                buildUserDetailTile('Name of the bank', userInfo['name_of_bank']),
                buildUserDetailTile('Name as in the bank', userInfo['name_as_in_bank']),
                buildUserDetailTile('IFSC code', userInfo['ifsc_code']),
                buildUserDetailTile('Branch', userInfo['bank_branch']),
                buildUserDetailTile('Account Number', userInfo['account_number']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserDetailTile(String title, String? detail) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
      subtitle: Text(
        detail ?? 'Not specified',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }
}
