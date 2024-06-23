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
  late String customerslevel; // Define customerslevel here


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
       customerslevel = data['customer']['level_one_count'].toString();
      print("level one customer : $customerslevel");
      _selectedCustomers = List<bool>.filled(customersJson.length, false);

      List<Customer> customers = customersJson.map((json) {
        return Customer.fromJson(json, customerslevel);
      }).toList();

      return customers;
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.blue,
            height: 4.0,
          ),
        ),
      ),


      body: Center(

        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Container(
            //color: Color(0xFFF0F4F8), // Light blue-gray background
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userProvider.userInfo['name'] ?? 'User'}!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your Refer ID: ${userProvider.userInfo['user_customer_number'] ?? ''}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  child: Expanded(
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blue, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: DataTable(
                                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[800]!),
                                dataRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[100]!),
                                headingTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                dataTextStyle: TextStyle(color: Colors.black),
                                columns:  <DataColumn>[
                                  DataColumn(
                                    label: Text("$customerslevel",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Name',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Mobile Number',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: customers.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Customer customer = entry.value;
                                  return DataRow(
                                    cells: <DataCell>[
                                      DataCell(
                                        Text(customer.levelOneCount),
                                      ),
                                      DataCell(Text(customer.name)),
                                      DataCell(Text(customer.mobileNumber)),
                                    ],
                                  );
                                }).toList(),
                              ),

                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Customer {
  final String name;
  final String mobileNumber;
  final String levelOneCount; // Add this field
  final String firstLevelCount; // New field for customerslevel


  Customer({
    required this.name,
    required this.mobileNumber,
    required this.levelOneCount,
    required this.firstLevelCount,

  });

  factory Customer.fromJson(Map<String, dynamic> json,String firstLevelCount) {
    return Customer(
      name: json['name'],
      mobileNumber: json['mobile_number'],
      levelOneCount: json['level_one_count'],
      firstLevelCount: firstLevelCount,


    );
  }
}

