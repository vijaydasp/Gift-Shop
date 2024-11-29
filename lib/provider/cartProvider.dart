import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  double get totalPrice => _cart.fold(
        0.0,
        (sum, item) => sum + (item['DiscountedPrice'] * item['Quantity']),
      );

  void addToCart(Map<String, dynamic> product) {
    final index = _cart
        .indexWhere((item) => item['Product_Name'] == product['Product_Name']);
    
    // Calculate the discounted price
    double originalPrice = double.parse(product['Price'].toString());
    double discountedPrice = originalPrice;
    var highestOffer;

    // Check if there are any offers
    if (product['offers'] != null && product['offers'].isNotEmpty) {
      // Find the highest percentage offer with robust parsing
      highestOffer = product['offers'].reduce((current, next) {
        double currentOffer = double.tryParse(
                current['Offer_Percentage'].toString()) ?? 0;
        double nextOffer = double.tryParse(
                next['Offer_Percentage'].toString()) ?? 0;
        return (currentOffer > nextOffer) ? current : next;
      });

      // Calculate discounted price
      double offerPercentage = double.tryParse(
              highestOffer['Offer_Percentage'].toString()) ?? 0;
      discountedPrice = originalPrice * (1 - (offerPercentage / 100));
    }

    if (index != -1) {
      if (_cart[index]['Quantity'] < _cart[index]['MaxQuantity']) {
        _cart[index]['Quantity']++;
      } else {
        // Product is already at max quantity, no action required.
      }
    } else {
      // Add product with initial quantity and max quantity
      // Include both original and discounted prices
      _cart.add({
        ...product,
        'Quantity': 1,
        'MaxQuantity': int.parse(product['Quantity']),
        'OriginalPrice': originalPrice,
        'DiscountedPrice': discountedPrice,
        'Offer': highestOffer // Optional: store offer details
      });
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

  // Improved isInCart to use product 'id' or 'Product_Name'
  bool isInCart(Map<String, dynamic> product) {
    return _cart.any((item) => item['Product_Name'] == product['Product_Name']);
  }

  void incrementQuantity(int index, BuildContext context) {
    if (_cart[index]['Quantity'] >= _cart[index]['MaxQuantity']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity limit reached!')),
      );
    } else {
      _cart[index]['Quantity']++;
      notifyListeners();
    }
  }

  void decrementQuantity(int index) {
    if (_cart[index]['Quantity'] > 1) {
      _cart[index]['Quantity']--;
    } else {
      removeFromCart(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}