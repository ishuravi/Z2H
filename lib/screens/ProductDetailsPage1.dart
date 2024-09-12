//
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart'; // Razorpay integration
//
//
// class ProductDetailsPageDemo extends StatefulWidget {
//   final Function(int) onTabChanged;
//   final List<String> imageUrls;
//   final String productName;
//   final String description;
//   final String price; // Changed to double for price
//   final String discount; // Changed to int for discount percentage
//   final String offer_price; // Changed to double for offer price
//
//   const ProductDetailsPageDemo({
//     Key? key,
//     required this.imageUrls,
//     required this.description,
//     required this.productName,
//     required this.price,
//     required this.discount,
//     required this.offer_price, required this.onTabChanged,
//   }) : super(key: key);
//
//   @override
//   _ProductDetailsPageState createState() => _ProductDetailsPageState();
// }
//
// class _ProductDetailsPageState extends State<ProductDetailsPageDemo> {
//   int quantity = 1;
//   bool showQuantitySelector = false;
//   late Razorpay _razorpay;
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     // Handle payment success
//     print("Payment success: ${response.paymentId}");
//     // Navigate to success page or perform further actions
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     // Handle payment failure
//     print("Payment error: ${response.code.toString()} - ${response.message}");
//     // Show error message or retry option
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     // Handle external wallet
//     print("External wallet: ${response.walletName}");
//     // Navigate to external wallet handling page or perform further actions
//   }
//   void _openCheckout() {
//     double offerPrice = double.parse(widget.price);
//     int amountInPaise = (offerPrice * 100).toInt();
//     print("amount type :$amountInPaise");
//     var options = {
//       'key': 'rzp_test_uWqmZQwTxrgIAK', // Replace with your Razorpay key
//       'amount': amountInPaise,
//       'name': 'Product Name',
//       'description': 'Payment for our work',
//       'prefill': {'contact': '9003498602', 'email': 'iswarya3202@gmail.com'},
//       "method": {
//         "netbanking": true,
//         "card": true,
//         "upi": true,
//         "wallet": true,
//         "emi": false,
//         "paylater": false
//       },
//       'external': {
//         "wallets": ["paytm", "GPay"]
//       }
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('Error: ${e.toString()}');
//     }
//   }
//   void _showBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const Text(
//                     'Product Details',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Name: ${widget.productName}',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.blue),
//                   ),
//                   Text(
//                     'Description: ${widget.description}',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   Text(
//                     'Original price: ₹ ${widget.price.toString()}', // Formatting double to two decimal places
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   Text(
//                     'Discount: ${widget.discount} %',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   Text(
//                     'Offer Price: ₹ ${widget.offer_price.toString()}', // Formatting double to two decimal places
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove),
//                         onPressed: () {
//                           setState(() {
//                             if (quantity > 1) {
//                               quantity--;
//                             }
//                           });
//                         },
//                       ),
//                       Text(
//                         quantity.toString(),
//                         style: const TextStyle(fontSize: 20),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             quantity+1;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _openCheckout, // Call _openCheckout method for Razorpay integration
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     child: const Text(
//                       'Payment',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 80.0,
//         backgroundColor: const Color(0xFFDCFFFF),
//         automaticallyImplyLeading: false,
//         title: Center(
//           child: Image.asset(
//             'assets/icons/client_logo.png',
//             fit: BoxFit.contain,
//             height: 200,
//             width: 200,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: CarouselSlider(
//                   items: widget.imageUrls.map((url) {
//                     return Image.network(
//                       url,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Text('Error loading image');
//                       },
//                     );
//                   }).toList(),
//                   options: CarouselOptions(
//                     height: 300,
//                     aspectRatio: 16 / 9,
//                     viewportFraction: 1.5,
//                     autoPlay: true,
//                     enlargeCenterPage: true,
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.productName,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue[900]),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.description,
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Original price: ₹ ${widget.price.toString()}',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.green[800],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Discount: ${widget.discount} %',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.green[800],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Offer price: ₹ ${widget.offer_price.toString()}',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.green[800],
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   showQuantitySelector = true;
//                 });
//                 _showBottomSheet();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               child: const Text(
//                 'Buy Now',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp( MaterialApp(
//     home: ProductDetailsPageDemo(
//       imageUrls: [
//         'https://example.com/image1.jpg',
//         'https://example.com/image2.jpg',
//         'https://example.com/image3.jpg',
//       ],
//       productName: 'Product Name',
//       description: 'Product Description',
//       price: '100',
//       discount: '100',
//       offer_price: '10', onTabChanged: (int ) {  },
//     ),
//   ));
// }
