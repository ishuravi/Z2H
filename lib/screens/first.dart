
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import '../token_provider.dart';
import 'ProductDetailsPage.dart';
import 'ProductDetailsPage1.dart';


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
    _beeController = VideoPlayerController.networkUrl(
      Uri.parse('https://file-examples.com/storage/fe42d5335b663a39f9c45ee/2017/04/file_example_MP4_480_1_5MG.mp4'),
    )..initialize().then((_) {
      setState(() {});
    });

    _butterflyController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    )..initialize().then((_) {
      setState(() {});
    });

    fetchProducts();
  }

  @override
  void dispose() {
    _beeController.dispose();
    _butterflyController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
    print('TokenFirstpage: $token');

    const url = 'https://z2h.in/api/z2h/app/products_list/';
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
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  suffixIcon: Icon(Icons.search),
                ),
                // Implement your search logic here
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: Card(
                  color: const Color(0xFFDCFFFF),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: CarouselSlider(
                    items: [
                      if (_beeController.value.isInitialized)
                        Stack(
                          children: [
                            VideoPlayer(_beeController),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: () {
                                  playPauseVideo(_beeController);
                                },
                                icon: Icon(
                                  _beeController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (_butterflyController.value.isInitialized)
                        Stack(
                          children: [
                            VideoPlayer(_butterflyController),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: () {
                                  playPauseVideo(_butterflyController);
                                },
                                icon: Icon(
                                  _butterflyController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                    options: CarouselOptions(
                      height: 200,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Available Products",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: CarouselSlider.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index, realIndex) {
                    final product = products[index];
                    List<String> productImageUrls = (product['product_image_urls'] as List<dynamic>)
                        .map<String>((image) => image['url'] as String)
                        .toList();
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(
                              imageUrls: productImageUrls,
                              productName: product['name'].toString(),
                              description: product['description'].toString(),
                              price: product['price'].toString(),
                              discount: product['discount'].toString(),
                              offer_price: product['offer_price'].toString(),
                              onTabChanged: (int ) {  },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: const Color(0xFFaaffff),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  productImageUrls.isNotEmpty
                                      ? productImageUrls[0]
                                      : 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name'] ?? 'No Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${product['description'] ?? 'No description'}',
                                style:  TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
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
        child: FirstPage(onTabChanged: (int ) {  }),
      ),
    ),
  );
}
