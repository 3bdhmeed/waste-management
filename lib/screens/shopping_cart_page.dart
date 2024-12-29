import 'package:flutter/material.dart';
import 'package:waste_management/screens/checkoutscreen.dart';

void main() {
  runApp(const ShoppingCartApp());
}

class ShoppingCartApp extends StatelessWidget {
  const ShoppingCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialCartItems = [
      {'name': 'G700 Pro Gaming Headset', 'price': 450.0, 'quantity': 1},
      {'name': 'Extended Warranty', 'price': 540.0, 'quantity': 2},
    ];

    return MaterialApp(
      title: 'Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: ShoppingCartPage(cartItems: initialCartItems),
    );
  }
}

class ShoppingCartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const ShoppingCartPage({super.key, required this.cartItems});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late final List<Map<String, dynamic>> _products;
  final Map<String, Map<String, dynamic>> _cart = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _products = [
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

    // Initialize the cart with prices from _products
    for (var item in widget.cartItems) {
      final product = _products.firstWhere(
        (p) => p['name'] == item['name'],
        orElse: () => {'name': item['name'], 'price': 0.0},
      );
      _cart[item['name']] = {
        'quantity': item['quantity'],
        'price': product['price'], // Ensure the correct price is stored
      };
    }
  }

  void _addToCart(String productName) {
    setState(() {
      if (_cart.containsKey(productName)) {
        _cart[productName]!['quantity']++;
      } else {
        final product = _products.firstWhere(
          (p) => p['name'] == productName,
          orElse: () => {'name': productName, 'price': 0.0},
        );
        _cart[productName] = {
          'quantity': 1,
          'price': product['price'],
        };
      }
    });
  }

  void _removeFromCart(String productName) {
    setState(() {
      if (_cart.containsKey(productName) &&
          _cart[productName]!['quantity'] > 0) {
        _cart[productName]!['quantity']--;
        if (_cart[productName]!['quantity'] == 0) {
          _cart.remove(productName);
        }
      }
    });
  }

  double _calculateTotal() {
    double total = 0.0;
    _cart.forEach((productName, details) {
      // Ensure that price and quantity are correctly cast to numeric types
      total += (details['price'] as double) * (details['quantity'] as int);
    });
    return total * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCart = _cart.keys
        .where((productName) =>
            productName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00b298),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search in cart...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00b298)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredCart.isEmpty
                ? const Center(
                    child: Text(
                      'No items match your search.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCart.length,
                    itemBuilder: (context, index) {
                      final productName = filteredCart[index];
                      final productDetails = _cart[productName]!;
                      final price = productDetails['price'] as double;
                      final quantity = productDetails['quantity'] as int;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'EGP ${price}k each ton',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeFromCart(productName),
                                  ),
                                  Text('$quantity',
                                      style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Color(0xFF00b298)),
                                    onPressed: () => _addToCart(productName),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF00b298).withOpacity(0.1),
              border: const Border(top: BorderSide(color: Color(0xFF00b298))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Subtotal: EGP ${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005570),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00b298),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _cart.isEmpty
                      ? null
                      : () {
                          // Proceed to Buy Action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckoutScreen()),
                          );
                        },
                  child: Text(
                    'Proceed to Buy (${_cart.values.fold<int>(0, (previousValue, element) => previousValue + (element['quantity'] as int))} items)',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
