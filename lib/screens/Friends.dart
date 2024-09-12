// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import '../token_provider.dart';
// import 'userProvider.dart';
//
// class FriendsDemo extends StatefulWidget {
//   final Function(int) onTabChanged;
//   const FriendsDemo({Key? key, required this.onTabChanged}) : super(key: key);
//
//   @override
//   State<FriendsDemo> createState() => _FriendsState();
// }
//
// class _FriendsState extends State<FriendsDemo> {
//   late Future<Map<String, dynamic>> futureData;
//   int currentLevel = 1;
//   Map<String, List<Customer>>? customerData;
//   Map<String, List<Customer>> groupedCustomers = {};
//   Map<String, String> counts = {};
//
//   // Sorting variables
//   int _sortColumnIndex = 0;
//   bool _sortAscending = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAndSetUserInfo();
//   }
//
//   Future<void> fetchAndSetUserInfo() async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     await userProvider.fetchAndSetUserInfo(context);
//     setState(() {
//       futureData = fetchData();
//
//
//     });
//   }
//
//   Future<Map<String, dynamic>> fetchData()  async {
//     final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
//     final token = tokenProvider.token ?? '';
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final customerUid = userProvider.userInfo['user_customer_uid'] ?? '';
//
//     final response = await http.get(
//       Uri.parse('https://z2h.in/api/z2h/user/customer/customer_details/?customer_uid=$customerUid'),
//       headers: {
//         'Authorization': 'Token $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final allCustomers = {
//         'first_level_customers': parseCustomers(data['first_level_customers']),
//         'second_level_customers': parseCustomers(data['second_level_customers']),
//         'third_level_customers': parseCustomers(data['third_level_customers']),
//         'fourth_level_customers': parseCustomers(data['fourth_level_customers']),
//       };
//       counts = {
//         'level_one_count': data['customer']['level_one_count']?.toString() ?? 'N/A',
//         'level_two_count': data['customer']['level_two_count']?.toString() ?? 'N/A',
//         'level_three_count': data['customer']['level_three_count']?.toString() ?? 'N/A',
//         'level_four_count': data['customer']['level_four_count']?.toString() ?? 'N/A',
//       };
//       groupCustomersByReferrer(allCustomers);
//       return {'customers': allCustomers, 'counts': counts};
//     } else {
//       throw Exception('Failed to load customers');
//     }
//   }
//
//   List<Customer> parseCustomers(List<dynamic> customersJson) {
//     return customersJson.map((json) {
//       return Customer.fromJson(json);
//     }).toList();
//   }
//
//   void groupCustomersByReferrer(Map<String, List<Customer>> allCustomers) {
//     groupedCustomers.clear();
//     allCustomers.forEach((level, customers) {
//       for (var customer in customers) {
//         if (customer.referrerId.isNotEmpty) {
//           groupedCustomers.putIfAbsent(customer.referrerId, () => []).add(customer);
//         }
//       }
//     });
//   }
//
//   void _sort<T>(Comparable<T> Function(Customer customer) getField, int columnIndex, bool ascending) {
//     setState(() {
//       customerData?['${_getLevelName(currentLevel)}_level_customers']?.sort((a, b) {
//         if (!ascending) {
//           final Customer c = a;
//           a = b;
//           b = c;
//         }
//         final Comparable<T> aField = getField(a);
//         final Comparable<T> bField = getField(b);
//         return Comparable.compare(aField, bField);
//       });
//       _sortColumnIndex = columnIndex;
//       _sortAscending = ascending;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFDCFFFF),
//         automaticallyImplyLeading: false,
//         toolbarHeight: 150,
//         title: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 25),
//                 Text(
//                   'Welcome, ${userProvider.userInfo['name'] ?? 'User'}!',
//                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Your Refer ID: ${userProvider.userInfo['user_customer_number'] ?? ''}',
//                   style: const TextStyle(fontSize: 16, color: Colors.black),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!['customers'].isEmpty) {
//             return const Center(child: Text('No data found'));
//           } else {
//             customerData = snapshot.data!['customers'];
//             counts = snapshot.data!['counts'] ?? {};
//             return Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Level $currentLevel Customers',
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Text(
//                     'Click the count information to detailed view',
//                     style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Text(
//                     'Total count of level $currentLevel: ${counts['level_${_getLevelName(currentLevel)}_count'] ?? 'N/A'}',
//                     style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       buildCustomerList(
//                         customerData?['${_getLevelName(currentLevel)}_level_customers'] ?? [],
//                         currentLevel,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   children: [
//                     if (currentLevel > 1)
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               currentLevel--;
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[800],
//                           ),
//                           child: const Text('Back', style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                     if (currentLevel < 4)
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               currentLevel++;
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[800],
//                           ),
//                           child: const Text(
//                             'Go to Next Level',
//                             style: TextStyle(
//                                 color: Colors.white, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Widget buildCustomerList(List<Customer> customers, int level) {
//     final columns = [
//       DataColumn(
//         label: const Text(
//           'List',
//           style: TextStyle(
//             fontStyle: FontStyle.italic,
//             color: Colors.white,
//           ),
//         ),
//         onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.levelOneCount, columnIndex, ascending),
//       ),
//       DataColumn(
//         label: const Text(
//           'Name',
//           style: TextStyle(
//             fontStyle: FontStyle.italic,
//             color: Colors.white,
//           ),
//         ),
//         onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.name, columnIndex, ascending),
//       ),
//       DataColumn(
//         label: const Text(
//           'Refer ID',
//           style: TextStyle(
//             fontStyle: FontStyle.italic,
//             color: Colors.white,
//           ),
//         ),
//         onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.customerNumber, columnIndex, ascending),
//       ),
//       if (level > 1)
//         DataColumn(
//           label: const Text(
//             'Referred By',
//             style: TextStyle(
//               fontStyle: FontStyle.italic,
//               color: Colors.white,
//             ),
//           ),
//           onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.referrerName, columnIndex, ascending),
//         ),
//       if (level == 1)
//         DataColumn(
//           label: const Text(
//             'Mobile Number',
//             style: TextStyle(
//               fontStyle: FontStyle.italic,
//               color: Colors.white,
//             ),
//           ),
//           onSort: (columnIndex, ascending) => _sort<String>((customer) => customer.mobileNumber, columnIndex, ascending),
//         ),
//     ];
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DataTable(
//               sortColumnIndex: _sortColumnIndex,
//               sortAscending: _sortAscending,
//               headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[800]!),
//               dataRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[50]!),
//               headingTextStyle: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//               dataTextStyle: const TextStyle(color: Colors.black),
//               columns: columns,
//               rows: customers.map((customer) {
//                 final cells = [
//                   DataCell(
//                     Text(customer.levelOneCount, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500)),
//                   ),
//                   DataCell(Text(customer.name)),
//                   DataCell(Text(customer.customerNumber)),
//                   if (level > 1) DataCell(Text('${customer.referrerName} (${customer.referrerId})')),
//                   if (level == 1) DataCell(Text(customer.mobileNumber)),
//                 ];
//
//                 return DataRow(cells: cells);
//               }).toList(),
//             ),
//             if (currentLevel < 4)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getLevelName(int level) {
//     switch (level) {
//       case 1:
//         return 'one';
//       case 2:
//         return 'two';
//       case 3:
//         return 'three';
//       case 4:
//         return 'four';
//       default:
//         return 'one';
//     }
//   }
// }
//
// class Customer {
//   final String name;
//   final String mobileNumber;
//   final String customerNumber;
//   final String levelOneCount;
//   final String referrerId;
//   final String referrerName;
//
//   Customer({
//     required this.name,
//     required this.mobileNumber,
//     required this.customerNumber,
//     required this.levelOneCount,
//     required this.referrerId,
//     required this.referrerName,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       name: json['name'] ?? 'N/A',
//       mobileNumber: json['mobile_number'] ?? 'N/A',
//       customerNumber: json['customer_number'] ?? 'N/A',
//       levelOneCount: json['level_one_count']?.toString() ?? 'N/A',
//       referrerId: json['referrer_id'] ?? '',
//       referrerName: json['referrer_name'] ?? 'N/A',
//     );
//   }
// }