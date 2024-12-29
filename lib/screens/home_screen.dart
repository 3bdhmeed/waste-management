import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'scan_screen.dart';
import 'product_description_page.dart'; // Import your description page
import 'shopping_cart_page.dart'; // Import your shopping cart
import 'user_location_screen.dart';
import 'company_location_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> cartItems = [];
  // List of Products
  final List<Map<String, dynamic>> products = [
    {
      "name": "Plastic",
      "description": "Recyclable plastic waste.",
      "rating": 4.5,
      "price": 5.0,
      "isFavorite": false,
      "imageUrl": "assets/images/Plastic.jpg"
    },
    {
      "name": "Metal",
      "description": "Recyclable metal scrap.",
      "rating": 4.7,
      "price": 10.0,
      "isFavorite": false,
      "imageUrl": "assets/images/Metal.jpg"
    },
    {
      "name": "Paper",
      "description": "Recyclable paper material.",
      "rating": 4.2,
      "price": 3.0,
      "isFavorite": false,
      "imageUrl": "assets/images/Paper.png"
    },
    {
      "name": "Glass",
      "description": "Recyclable glass material.",
      "rating": 4.8,
      "price": 8.0,
      "isFavorite": false,
      "imageUrl": "assets/images/Glass.jpg"
    },
    {
      "name": "Cardboard",
      "description": "Recyclable cardboard.",
      "rating": 4.3,
      "price": 4.0,
      "isFavorite": false,
      "imageUrl": "assets/images/Cardboard.jpg"
    },
    {
      "name": "Clothes",
      "description": "Reusable clothing items.",
      "rating": 4.6,
      "price": 7.0,
      "isFavorite": false,
      "imageUrl": "assets/images/Clothes.png"
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Filtered list based on search query
    final filteredProducts = products.where((product) {
      return product['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          // Menu actionicon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
        ),
        backgroundColor: Color(0xFF00b298),
        elevation: 0,
        title: const Text(
          "Home",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              // Navigate to the ShoppingCartPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingCartPage(cartItems: cartItems),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            // Profile Image and Search Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  radius: screenWidth * 0.06,
                  child: Icon(Icons.person, color: Colors.grey.shade700),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: "Search",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            // Popular Section
            const Text(
              "Popular",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Popular Items (GridView)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate dynamic aspect ratio
                  double cardWidth =
                      constraints.maxWidth / 2 - 10; // 2 items per row
                  double cardHeight =
                      cardWidth * 1.5; // Adjust the multiplier as needed
                  double aspectRatio = cardWidth / cardHeight;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of items per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDescriptionPage(
                                product: product,
                                cartItems: cartItems,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        width: double.infinity,
                                        product[
                                            'imageUrl'], // Use Image.network for online images
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product['description'],
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "EGP ${product['price']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        product['isFavorite']
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: product['isFavorite']
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          product['isFavorite'] =
                                              !product['isFavorite'];
                                        });
                                      },
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.yellow, size: 16),
                                    Text(
                                      product['rating'].toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Location",
          ),
        ],
        selectedItemColor: Color(0xFF00b298),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScanScreen()),
            );
          } else if (index == 2) {
            // Check the user's role before navigating
            try {
              // Get the current user
              User? currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null) {
                // Retrieve the user's role from Firebase using the user's ID
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid) // Use the current user's UID
                    .get();

                // Get the role (citizen or company)
                String role = userSnapshot['userType'];

                // Navigate based on the role
                if (role == 'Citizen') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreenUser()),
                  );
                } else if (role == 'Company') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreenCompany()),
                  );
                } else {
                  // Handle unknown role
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unknown role: $role')),
                  );
                }
              } else {
                // If no user is logged in
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No user is logged in')),
                );
              }
            } catch (e) {
              // Handle errors (e.g., error fetching user role)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error fetching user role: $e')),
              );
            }
          }
        },
      ),
    );
  }
}
