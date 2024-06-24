import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zero2hero/screens/userProvider.dart';

import '../token_provider.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  List<OrderDetail> orderDetails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final customerUid = userProvider.userInfo['user_customer_uid'] ?? '';
    final response = await http.get(
      Uri.parse('https://z2h.in:8000/api/z2h/user/customer/customer_details/?customer_uid=$customerUid'),
      headers: {
        'Authorization': 'Token $token', // Replace with your token provider logic
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orderDetails = (data['customer']['order_details'] as List)
            .map((json) => OrderDetail.fromJson(json))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order details')),
      );
    }
  }

  void _showDetailsDialog(OrderDetail orderDetail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details', style: TextStyle(color: Colors.green[900])),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(' ${orderDetail.productName}'),
                Text('Payment Status: ${orderDetail.paymentStatus}'),
                Text('Payment Mode: ${orderDetail.paymentMode}'),
                Text('Payment Date: ${orderDetail.paymentDate}'),
                Text('Order Status: ${orderDetail.orderStatus}'),
                Text('Customer Name: ${orderDetail.customerName}'),
                Text('Quantity: ${orderDetail.quantity}'),
                Text('Price: ${orderDetail.price}'),
                Text('GST amount: ${orderDetail.gstAmount}'),
                Text('Total Amount: ${orderDetail.totalAmount}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(); // Use rootNavigator: true
              },
              child: Text('Close', style: TextStyle(color: Colors.green[900])),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130.0,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orderDetails.isEmpty
          ? Center(child: Text('No records found'))
          : ListView.builder(
        itemCount: orderDetails.length,
        itemBuilder: (context, index) {
          final orderDetail = orderDetails[index];
          return Card(
            color: Colors.blue[50],
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.green),
              title: Text(' ${orderDetail.productName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Date: ${orderDetail.paymentDate}'),
                  Text('Total Amount: ${orderDetail.totalAmount}'),
                  Text('Payment Status: ${orderDetail.paymentStatus}',style: TextStyle(color: Colors.green[800],fontWeight: FontWeight.bold),),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
              onTap: () => _showDetailsDialog(orderDetail),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetail {
  final String paymentStatus;
  final String productName;
  final String paymentDate;
  final String totalAmount;
  final String orderStatus;
   final String paymentMode;
   final String customerName;
   final String quantity;
  final String price;
  final String gstAmount;



  OrderDetail({
    required this.paymentStatus,
    required this.productName,
    required this.paymentDate,
    required this.totalAmount,
   required this.orderStatus,
    required this.paymentMode,
   required this.customerName,
   required this.quantity,
  required this.price,
    required this.gstAmount,

  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      paymentStatus: json['payment_status'],
      productName: json['order_items'][0]['product_name'],
      paymentDate: json['payment_date'],
      totalAmount: json['order_items'][0]['total_amount'],
      orderStatus: json['order_status'],
      paymentMode: json['payment_mode'],
       customerName: json['customer_name'],
      quantity: json['order_items'][0]['quantity'].toString(),
      price: json['order_items'][0]['price'].toString(),
     gstAmount: json['order_items'][0]['gst_total_amount'].toString(),
    );
  }
}
