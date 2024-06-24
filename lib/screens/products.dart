import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  String token = ''; // Initialize token variable

  @override
  void initState() {
    super.initState();
    fetchTokenAndProducts();
  }

  Future<void> fetchTokenAndProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? ''; // Get token from SharedPreferences
    print('Tokenproducts: $token');

    if(token.isEmpty) {
      // Redirect to login page or handle token absence
      return;
    }

    fetchProducts(); // Fetch products after getting the token
  }

  Future<void> fetchProducts() async {
    const url = 'https://z2h.in:8000/api/z2h/app/product_categories/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token', // Set token in the headers
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        isLoading = false; // Set loading to false after data is fetched
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007dfe),
        automaticallyImplyLeading: false, // Set to false to remove the default back button
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.search, color: Colors.black),
            ),
            onTap: () {
              // Implement search functionality
            },
          ),
        ),
        leading: IconButton( // Add leading property with IconButton
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Back arrow icon
          onPressed: () {
            // Implement back button functionality
          },
        ),
        actions: const [],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      )
          : products.isEmpty
          ? const Center(
        child: Text('No products available'),
      )
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of cards per row
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 2.0,
            color: Colors.cyanAccent[100],
            child: InkWell(
              onTap: () {
                // Handle category tap
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product['description'] ?? 'No Description',
                    textAlign: TextAlign.center,
                  ),
                  // Placeholder if imageurl is null
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
