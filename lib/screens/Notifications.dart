import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../token_provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool isUserUnderNoPlan = false;
  bool isFirstLogin = false;
  bool isLoading = true;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final url = Uri.parse('https://z2h.in/api/z2h/user/info/?accessed_from=mobile');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("is_user_under_no_plan: ${data['user_info']['is_user_under_no_plan']}");
      print("is_first_login: ${data['user_info']['is_first_login']}");
      print("registered_users_under_user: ${data['user_info']['registered_users_under_user']}");
      print("product_purchased_users_under_user: ${data['user_info']['product_purchased_users_under_user']}");
      print("level_completed_status_of_user: ${data['user_info']['level_completed_status_of_user']}");

      setState(() {
        isUserUnderNoPlan = data['user_info']['is_user_under_no_plan'];
        isFirstLogin = data['user_info']['is_first_login'];
        notifications = [
          ...data['user_info']['registered_users_under_user'].map((user) => {
            "message": "Your friend, ${user['name']}, with reference ID ${user['customer_number']} has registered with us. Please share more details about our products with them.",
            "isRead": false,
          }),
          ...data['user_info']['product_purchased_users_under_user'].map((user) => {
            "message": "Your friend, ${user['name']}, with reference ID ${user['customer_number']} has purchased our product.",
            "isRead": false,
          }),
        ];

        // Modify this condition to check if either of the variables is true
        if (isUserUnderNoPlan || isFirstLogin) {
          notifications.insert(0, {
            "message": "Thank you for registering with us! Please take a moment to explore our products section.",
            "isRead": false,
          });
        }

        isLoading = false;
      });


      checkForNotifications();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user info')),
      );
    }
  }

  void checkForNotifications() {
    if (notifications.isNotEmpty) {
      // Any notification checks can be done here
    }
  }

  void markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void showNotificationDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Notification Details',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: Colors.blue,
      dismissOnTouchOutside: true,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: false,
        title: Center(
          child: Image.asset(
            'assets/icons/client_logo.png',
            fit: BoxFit.contain,
            height: 150,
            width: 150,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {},
              ),
              if (notifications.any((n) => !n['isRead']))
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      notifications.where((n) => !n['isRead']).length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ListTile(
              tileColor: notification['isRead']
                  ? Colors.grey[200]
                  : Colors.blue[50],
              title: Text(
                "Click to view the notification",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  notification['message'],
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              trailing: notification['isRead']
                  ? null
                  : IconButton(
                icon: const Icon(Icons.notifications_active,
                    color: Colors.blue),
                onPressed: () => markAsRead(index),
              ),
              onTap: () {
                markAsRead(index);
                showNotificationDialog(notification['message']);
              },
            ),
          );
        },
      ),
    );
  }
}
