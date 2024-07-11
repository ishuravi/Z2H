import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:zero2hero/screens/ProductDetailsPage1.dart';

import '../token_provider.dart';
import 'ProductDetailsPage.dart';

class FirstPage extends StatefulWidget {
  final Function(int) onTabChanged;
   const FirstPage({Key? key, required this.onTabChanged}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  late VideoPlayerController _beeController;
  late VideoPlayerController _butterflyController;
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _beeController = VideoPlayerController.network(
      'https://file-examples.com/storage/fe42d5335b663a39f9c45ee/2017/04/file_example_MP4_480_1_5MG.mp4',
    )..initialize().then((_) {
        setState(() {});
      });

    _butterflyController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    )..initialize().then((_) {
        setState(() {});
      });

    fetchProducts();
  }

  @override
  void dispose() {
    super.dispose();
    _beeController.dispose();
    _butterflyController.dispose();
  }

  Future<void> fetchProducts() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    print('TokenFirstpage: $token');

    const url = 'https://z2h.in:8000/api/z2h/app/products_list/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final uid = responseBody[0]['uid'];
      tokenProvider.setUid(uid);

      print("product uid: $uid");
      setState(() {
        products = responseBody;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }



  void playPauseVideo(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color: Colors.white,
        // child: isLoading
        //     ? const Center(
        //         child: CircularProgressIndicator(),
        //       )
            child:Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 30), // Adjust padding as needed
                   // color: Colors.white,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for products...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                        suffixIcon: Icon(Icons.search),
                      ),
                      // Implement your search logic here
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 200, // Set height for the video carousel
                      child: Card(
                        color: Color(0xFFDCFFFF),
                        child: CarouselSlider(
                          items: [
                            if (_beeController.value.isInitialized)
                              Stack(
                                children: [
                                  VideoPlayer(_beeController),
                                  IconButton(
                                    onPressed: () {
                                      playPauseVideo(_beeController);
                                    },
                                    icon: Icon(
                                      _beeController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            if (_butterflyController.value.isInitialized)
                              Stack(
                                children: [
                                  VideoPlayer(_butterflyController),
                                  IconButton(
                                    onPressed: () {
                                      playPauseVideo(_butterflyController);
                                    },
                                    icon: Icon(
                                      _butterflyController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                          options: CarouselOptions(
                            height: 500,
                            aspectRatio: _beeController.value.aspectRatio,
                            viewportFraction: 1.0,
                            autoPlay: false,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                          ),
                        ),
                      ),
                    ),
                  ),
                   Padding(
                     padding: const EdgeInsets.only(right: 180),
                     child: Text("Available Products",style: TextStyle(fontSize: 20, color: Colors.blue[900]),),
                   ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: CarouselSlider.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index, realIndex) {
                          final product = products[index];
                          List<String> productImageUrls= (product['product_image_urls'] as List<dynamic>)
                              .map<String>((image) => image['url'] as String)
                              .toList();
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsPageDemo(
                                    imageUrls: productImageUrls,
                                    productName: product['name'].toString(),
                                    description: product['description'].toString(),
                                    price: product['price'].toString(),
                                    discount: product['discount'].toString(),
                                    offer_price: product['offer_price'].toString(), onTabChanged: (int ) {  },
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shadowColor: Colors.blue,
                              elevation: 19,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              color: Color(0xFFaaffff),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Image.network(
                                        productImageUrls.isNotEmpty
                                            ? productImageUrls[0]
                                            : 'https://via.placeholder.com/150',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      product['name'] ?? 'No Name',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 1),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              '${product['description'] ?? 'No description'}',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 300,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: false,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // onPageChange function
                          },
                          scrollDirection: Axis.horizontal,
                        ),
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
  runApp(
    MaterialApp(
      title: 'Product App',
      home: ChangeNotifierProvider<TokenProvider>(
        create: (context) => TokenProvider(),
        child:  FirstPage(onTabChanged: (int ) {  },),
      ),
    ),
  );
}
