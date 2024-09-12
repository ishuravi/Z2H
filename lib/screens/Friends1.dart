import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../token_provider.dart';
import 'userProvider.dart';

class FriendsDemo extends StatefulWidget {
  final Function(int) onTabChanged;
  const FriendsDemo({Key? key, required this.onTabChanged}) : super(key: key);

  @override
  State<FriendsDemo> createState() => _FriendsState();
}

class _FriendsState extends State<FriendsDemo> {
  late Future<Map<String, List<Customer>>> futureCustomers;
  int currentLevel = 1;
  Map<String, List<Customer>>? customerData;
  Map<String, List<Customer>> groupedCustomers = {};
  Map<String, String> counts = {};

  // Sorting variables
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

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

  Future<Map<String, List<Customer>>> fetchCustomers() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final customerUid = userProvider.userInfo['user_customer_uid'] ?? '';

    final response = await http.get(
      Uri.parse('https://z2h.in/api/z2h/user/customer/customer_details/?customer_uid=$customerUid'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final allCustomers = {
        'first_level_customers': parseCustomers(data['first_level_customers']),
        'second_level_customers': parseCustomers(data['second_level_customers']),
        'third_level_customers': parseCustomers(data['third_level_customers']),
        'fourth_level_customers': parseCustomers(data['fourth_level_customers']),
      };
      setState(() {
        counts = {
          'level_one_count': data['customer']['level_one_count']?.toString() ?? 'N/A',
          'level_two_count': data['customer']['level_two_count']?.toString() ?? 'N/A',
          'level_three_count': data['customer']['level_three_count']?.toString() ?? 'N/A',
          'level_four_count': data['customer']['level_four_count']?.toString() ?? 'N/A',
        };
      });
      print("counts: $counts");
      groupCustomersByReferrer(allCustomers);
      return allCustomers;
    } else {
      throw Exception('Failed to load customers');
    }
  }

  List<Customer> parseCustomers(List<dynamic> customersJson) {
    return customersJson.map((json) {
      return Customer.fromJson(json);
    }).toList();
  }

  void groupCustomersByReferrer(Map<String, List<Customer>> allCustomers) {
    groupedCustomers.clear();
    allCustomers.forEach((level, customers) {
      for (var customer in customers) {
        if (customer.referrerId.isNotEmpty) {
          groupedCustomers.putIfAbsent(customer.referrerId, () => []).add(customer);
        }
      }
    });
  }

  void _sort<T>(Comparable<T> Function(Customer customer) getField, int columnIndex, bool ascending) {
    setState(() {
      customerData!['${_getLevelName(currentLevel)}_level_customers']!.sort((a, b) {
        if (!ascending) {
          final Customer c = a;
          a = b;
          b = c;
        }
        final Comparable<T> aField = getField(a);
        final Comparable<T> bField = getField(b);
        return Comparable.compare(aField, bField);
      });
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: false,
        toolbarHeight: 220, // Adjust height as needed
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                // Logo
                Image.asset(
                  'assets/icons/client_logo.png',
                  fit: BoxFit.fitHeight,
                  height: 150, // Adjust size as needed
                  width: 150,  // Adjust size as needed
                ),
                SizedBox(height:1), // Space between logo and text
                // User Information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${userProvider.userInfo['name'] ?? 'User'}!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFDCFFFF)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Refer ID: ${userProvider.userInfo['user_customer_number'] ?? ''}',
                      style: TextStyle(fontSize: 16, color: Color(0xFFDCFFFF),fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),


      body: FutureBuilder<Map<String, List<Customer>>>(
        future: futureCustomers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            customerData = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[200]!, Colors.blue[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Level $currentLevel Customers',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Total count of level $currentLevel: ${counts[_getCountKey(currentLevel)] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      buildCustomerList(
                        customerData!['${_getLevelName(currentLevel)}_level_customers']!,
                        currentLevel,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (currentLevel > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              currentLevel--;
                            });
                          },
                          icon: Icon(Icons.arrow_back,color: Colors.white,),
                          label: Text('Back',style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          ),
                        ),
                      ),
                    if (currentLevel < 4)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              currentLevel++;
                            });
                          },
                          icon: Icon(Icons.arrow_forward,color: Colors.white,),
                          label: Text('View Next Level',style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildCustomerList(List<Customer> customers, int level) {
    final columns = [
      DataColumn(
        label: const Text(
          'List',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.levelOneCount, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text(
          'Name',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.name, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text(
          'Refer ID',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.customerNumber, columnIndex, ascending),
      ),
      if (level > 1) DataColumn(
        label: const Text(
          'Referrer',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.referrerName, columnIndex, ascending),
      ),
      if (level == 1) DataColumn(
        label: const Text(
          'Mobile Number',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.mobileNumber, columnIndex, ascending),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[800]!),
        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[50]!),
        headingTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        dataTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
        columns: columns,
        rows: customers.map((customer) {
          final cells = [
            DataCell(
              Text(customer.levelOneCount, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500)),
            ),
            DataCell(Text(customer.name)),
            DataCell(Text(customer.customerNumber)),
            if (level > 1) DataCell(Text('${customer.referrerName} (${customer.referrerId})')),
            if (level == 1) DataCell(Text(customer.mobileNumber)),
          ];

          return DataRow(cells: cells);
        }).toList(),
      ),
    );
  }


  String _getLevelName(int level) {
    switch (level) {
      case 1: return 'first';
      case 2: return 'second';
      case 3: return 'third';
      case 4: return 'fourth';
      default: return '';
    }
  }

  String _getCountKey(int level) {
    switch (level) {
      case 1: return 'level_one_count';
      case 2: return 'level_two_count';
      case 3: return 'level_three_count';
      case 4: return 'level_four_count';
      default: return '';
    }
  }
}

class Customer {
  final String name;
  final String customerNumber;
  final String referrerId;
  final String referrerName;
  final String mobileNumber;
  final String levelOneCount;

  Customer({
    required this.name,
    required this.customerNumber,
    required this.referrerId,
    required this.referrerName,
    required this.mobileNumber,
    required this.levelOneCount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      customerNumber: json['customer_number'],
      referrerId: json['referrer_id'],
      referrerName: json['referrer_name'],
      mobileNumber: json['mobile_number'],
      levelOneCount: json['level_one_count'],
    );
  }
}
