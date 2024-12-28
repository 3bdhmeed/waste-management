import 'package:flutter/material.dart';
import 'shopping_cart_page.dart';

class ProductDescriptionPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> cartItems;

  // Default Constructor
  const ProductDescriptionPage({
    super.key,
    required this.product,
    required this.cartItems,
  });

  // Named Constructor
  ProductDescriptionPage.simple({
    super.key,
    required this.product,
  }) : cartItems = [];

  @override
  _ProductDescriptionPageState createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  int quantity = 1;

  void addToCart() {
    final existingItemIndex = widget.cartItems
        .indexWhere((item) => item['name'] == widget.product['name']);

    if (existingItemIndex != -1) {
      widget.cartItems[existingItemIndex]['quantity'] += quantity;
    } else {
      widget.cartItems.add({
        ...widget.product,
        'quantity': quantity,
        'price': widget.product['price'],
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['name']} added to cart!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['name'],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00b298),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShoppingCartPage(cartItems: widget.cartItems),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.product['imageUrl'],
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.product['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product['description'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    Text(
                      widget.product['rating'].toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "EGP ${widget.product['price']}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quantity:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00b298),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: addToCart,
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
