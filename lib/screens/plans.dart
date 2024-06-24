import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  PlansPageState createState() => PlansPageState();
}

class PlansPageState extends State<PlansPage> {
  List<dynamic> plans = [];
  String token = ''; // Initialize token variable

  @override
  void initState() {
    super.initState();
    fetchTokenAndData();
  }

  Future<void> fetchTokenAndData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? ''; // Get token from SharedPreferences
    print('Tokenplans: $token');
     // Print the token
    fetchData(); // Fetch plans after getting the token
  }

  Future<void> fetchData() async {
    const url = 'https://z2h.in:8000/api/z2h/app/plan_details/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        plans = json.decode(response.body);
      });
    } else {
      print('Failed to load plans: ${response.statusCode}');
      print('Error message: ${response.body}');
      throw Exception('Failed to load plans: ${response.statusCode}');
    }
  }


  Color getColorForIndex(int index) {
    List<Color> colors = [
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black
      // Add more colors as needed
    ];
    return colors[index % colors.length];
  }

  Color getContainerColorForIndex(int index) {
    List<Color> containerColors = [
      Colors.grey,
      Colors.amber,
      Colors.white38,
      Colors.teal,
      Colors.black12
      // Add more colors as needed
    ];
    return containerColors[index % containerColors.length];
  }

  List<String> assetImagePaths = [
    'assets/plans/silver.jpg',
    'assets/plans/gold.jpg',
    'assets/plans/platinum.jpg',
    'assets/plans/emrald.jpg',
    'assets/plans/diamond.jpg',

    // Add more image paths as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007dfe),
        title: const Text(
          "Choose Your Plan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: plans.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: plans.asMap().entries.map<Widget>((entry) {
            int index = entry.key;
            dynamic plan = entry.value;
            Color nameColor = getColorForIndex(index);
            Color containerColor = getContainerColorForIndex(index);

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                elevation: 2,
                color: Colors.lightBlue[100],
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30.0),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(150.0),
                              ),
                            ),
                            height: 150.0,
                            width: 300.0,
                            child: Text(
                              plan['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: nameColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                30.0, 30.0, 30.0, 10.0),
                            child: Text(
                              'Registration Fee: ${plan['registration_fee']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                60.0, 100.0, 20.0, 20.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your function here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Register Here',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(70.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(assetImagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                              color: containerColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(150.0),
                              ),
                            ),
                            height: 150.0,
                            width: 300.0,
                            child: const Text(
                              '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
