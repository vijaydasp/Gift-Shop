import 'package:flutter/material.dart';
import 'package:gift_shop/ipaddress_page.dart';
import 'package:gift_shop/provider/cartProvider.dart';
import 'package:gift_shop/screens/cart/confirmation_cart.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _checkout() async {
    await ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to Checkout...')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Page'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Check if the cart is empty
          if (cartProvider.cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/no_cart.jpeg', // Replace with your image path
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          // If the cart is not empty, show the list of products
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cart[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        leading: Image.network(
                          '$baseurl${item['Image']}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['Product_Name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show both original and discounted prices
                            RichText(
                              text: TextSpan(
                                children: [
                                  // Original Price (if different from discounted)
                                  if (item['OriginalPrice'] != item['DiscountedPrice'])
                                    TextSpan(
                                      text: '\$${item['OriginalPrice'].toStringAsFixed(2)} ',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  // Discounted Price
                                  TextSpan(
                                    text: '\$${item['DiscountedPrice'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: item['OriginalPrice'] != item['DiscountedPrice'] 
                                        ? Colors.green 
                                        : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Offer details if applicable
                            if (item['Offer'] != null)
                              Text(
                                '${item['Offer']['Offer_Percentage']}% OFF',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    cartProvider.decrementQuantity(index);
                                  },
                                ),
                                Text('${item['Quantity']}', style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                    cartProvider.incrementQuantity(index, context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            cartProvider.removeFromCart(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        Text(
                          '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                          )
                        ),
                      ],
                    ),
                    // Optional: Show total savings
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        double totalOriginalPrice = cartProvider.cart.fold(
                          0.0, 
                          (sum, item) => sum + (item['OriginalPrice'] * item['Quantity'])
                        );
                        double totalSavings = totalOriginalPrice - cartProvider.totalPrice;

                        return totalSavings > 0 
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'You saved \$${totalSavings.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}