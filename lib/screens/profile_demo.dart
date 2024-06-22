import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero2hero/screens/edit_profile.dart';
import '../services/api_service.dart';
import '../services/shared_preference.dart';

class ProfileDemo extends StatefulWidget {
  const ProfileDemo({super.key});

  @override
  State<ProfileDemo> createState() => _ProfileDemoState();
}

class _ProfileDemoState extends State<ProfileDemo> {
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAndSaveUserInfo();
  }

  Future<void> fetchAndSaveUserInfo() async {
    try {
      final userInfo = await ApiService.fetchUserInfo(context);
      await SharedPreferencesService.saveUserInfo(userInfo['user_info']);
      final storedUserInfo = await SharedPreferencesService.getUserInfo();
      setState(() {
        this.userInfo = storedUserInfo;
        isLoading = false;
      });
    } catch (e) {
      // Handle the error appropriately here
      print('Failed to fetch and save user info: $e');
    }
  }

  Future<void> _showReferrerDetailsDialog() async {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your Referral ID', style: TextStyle(color: Colors.blue[900])),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${userInfo['user_customer_uid'] ?? 'Not specified'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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

  @override
  Widget build(BuildContext context) {
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
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.blue[900],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                          backgroundColor: Colors.black,
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

  Widget buildUserDetailTile(String title, String detail) {
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
