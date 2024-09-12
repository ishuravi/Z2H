import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../token_provider.dart';
import '../screens/first.dart'; // Adjust the path as per your project structure

class ProductDetailsPage extends StatefulWidget {
  final Function(int) onTabChanged;
  final List<String> imageUrls;
  final String productName;
  final String description;
  final String price; // Changed to double for price
  final String discount; // Changed to int for discount percentage
  final String offer_price; // Changed to double for offer price

  const ProductDetailsPage({
    Key? key,
    required this.imageUrls,
    required this.description,
    required this.productName,
    required this.price,
    required this.discount,
    required this.offer_price, required this.onTabChanged,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  bool showQuantitySelector = false;

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Name: ${widget.productName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.blue),
                  ),
                  Text(
                    'Description: ${widget.description}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Original price: ₹ ${widget.price.toString()}', // Formatting double to two decimal places
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Discount: ${widget.discount} %',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Offer Price: ₹ ${widget.offer_price.toString()}', // Formatting double to two decimal places
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity+1;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showSkipDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSkipDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      desc: 'Are you sure you want to buy this product?',
      btnCancelOnPress: () {
        print("Cancel Pressed");
      },
      btnOkOnPress: () async {
        // Call the payment API
        final response = await _callPaymentAPI();

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final customerUid = responseData['customer_uid'];

          // Show success dialog with customer UID
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            desc: 'Payment successful! \nCustomer UID: $customerUid',
            btnOkOnPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirstPage(onTabChanged: (int ) {  },)),
              );
            },
          )..show();
        } else {
          // Show error dialog
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            desc: 'Already done with the payment!',
            btnOkOnPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirstPage(onTabChanged: (int ) {  },)),
              );

            },
          )..show();
        }
      },
    )..show();
  }

  Future<http.Response> _callPaymentAPI() {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    final uid = tokenProvider.uid;
    print("Product details page token:$token");
    print("Product details page uid:$uid");
    final url = Uri.parse('https://z2h.in/api/z2h/app/update_payment/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
    final body = json.encode({
      'payment_mode': 'Phone pe',
      'payment_status': 'success',
      'payment_reference': 'GHJK24581245',
      'product': uid,
    });

    return http.post(url, headers: headers, body: body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: const Color(0xFFDCFFFF),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                // child: CarouselSlider(
                //   items: widget.imageUrls.map((url) {
                //     return Image.network(
                //       url,
                //       fit: BoxFit.cover,
                //       errorBuilder: (context, error, stackTrace) {
                //         return const Text('Error loading image');
                //       },
                //     );
                //   }).toList(),
                //   options: CarouselOptions(
                //     height: 300,
                //     aspectRatio: 16 / 9,
                //     viewportFraction: 1.5,
                //     autoPlay: true,
                //     enlargeCenterPage: true,
                //   ),
                // ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.productName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue[900]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Original price: ₹ ${widget.price.toString()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Discount: ${widget.discount} %',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Offer price: ₹ ${widget.offer_price.toString()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Colors.green[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showQuantitySelector = true;
                });
                _showBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp( MaterialApp(
    home: ProductDetailsPage(
      imageUrls: [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ],
      productName: 'Product Name',
      description: 'Product Description',
      price: '100',
      discount: '100',
      offer_price: '10', onTabChanged: (int ) {  },
    ),
  ));
}
