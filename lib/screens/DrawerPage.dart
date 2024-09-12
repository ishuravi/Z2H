import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zero2hero/screens/PaymentsPage.dart';
import 'package:zero2hero/screens/details.dart';
import 'package:zero2hero/screens/profile_demo1.dart';
import 'package:zero2hero/screens/settings.dart';
import 'dart:convert';

import '../token_provider.dart';
import 'Notifications.dart';
import 'login_page.dart';

class DrawerPage extends StatefulWidget {
  final Function(int) onTabChanged;

  const DrawerPage({Key? key, required this.onTabChanged}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  String? profilePhotoPath;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    final url =
        'https://z2h.in/api/z2h/user/info/?accessed_from=mobile';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Token $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userInfo = data['user_info'];
      setState(() {
        profilePhotoPath = userInfo['profile_photo_path'];
      });
    } else {
      throw Exception('Failed to load user information');
    }
  }
  Future<void> _refreshPage() async {
    // Fetch user information again
    await fetchUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 250,
              child: DrawerHeader(
                decoration:  BoxDecoration(
                  color: Colors.blue[900],
                ),
                child: GestureDetector(
                  onTap: _refreshPage,
                  child: Center(
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.white,
                      backgroundImage: profilePhotoPath != null ? NetworkImage(profilePhotoPath!) : null, // Placeholder image
                      child: profilePhotoPath == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                widget.onTabChanged(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileDemo1()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notifications()),
                );// Handle notifications navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Payment History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>const PaymentHistory()),
                );
                // onTabChanged(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Friends'),
              onTap: () {
                widget.onTabChanged(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const LoginPage();
                    },
                  ),
                      (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
