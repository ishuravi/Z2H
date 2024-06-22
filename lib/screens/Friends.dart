import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zero2hero/screens/userProvider.dart';
import '../token_provider.dart';

class Friends extends StatefulWidget {
  final Function(int) onTabChanged;
  const Friends({Key? key, required this.onTabChanged}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  late Future<List<Customer>> futureCustomers;
  List<bool> _selectedCustomers = [];

  Future<List<Customer>> fetchCustomers() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final customerUid = userProvider.userInfo['user_customer_uid'] ?? '';

    final response = await http.get(
      Uri.parse('http://154.61.75.25:8000/api/z2h/user/customer/customer_details/?customer_uid=$customerUid'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> customersJson = data['first_level_customers'];
      _selectedCustomers = List<bool>.filled(customersJson.length, false);
      return customersJson.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetUserInfo();
  }

  Future<void> fetchAndSetUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchAndSetUserInfo(context);
    setState(() {
      futureCustomers = fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: Color(0xFFDCFFFF),
        automaticallyImplyLeading: false,
        title: Center(
          child: Image.asset(
            'assets/icons/client_logo.png',
            fit: BoxFit.contain,
            height: 200,
            width: 200,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userProvider.userInfo['name'] ?? 'User'}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'User Refer ID: ${userProvider.userInfo['user_customer_number'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: futureCustomers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found'));
                } else {
                  final customers = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('List')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Mobile Number')),
                      ],
                      rows: customers.asMap().entries.map((entry) {
                        int index = entry.key;
                        Customer customer = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(
                              Checkbox(
                                value: _selectedCustomers[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedCustomers[index] = value ?? false;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(customer.name)),
                            DataCell(Text(customer.mobileNumber)),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Customer {
  final String name;
  final String mobileNumber;

  Customer({required this.name, required this.mobileNumber});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      mobileNumber: json['mobile_number'],
    );
  }
}
