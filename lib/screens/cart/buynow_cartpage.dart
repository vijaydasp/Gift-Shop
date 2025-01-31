import 'package:flutter/material.dart';
import 'package:gift_shop/ipaddress_page.dart';
import 'package:gift_shop/screens/cart/buynow_confirmationpage.dart';

class BuynowCartPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const BuynowCartPage({super.key, required this.product});

  @override
  _BuynowCartPageState createState() => _BuynowCartPageState();
}

class _BuynowCartPageState extends State<BuynowCartPage> {
  late int _quantity;
  late double _originalPrice;
  late double _discountedPrice;
  late Map<String, dynamic>? _highestOffer;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _originalPrice = double.parse(widget.product['Price'].toString());
    _discountedPrice = _calculateDiscountedPrice();
    _highestOffer = _getHighestOffer();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _proceedToConfirmation() {
    // Create a buy now cart item with selected quantity
    final buyNowItem = {
      ...widget.product,
      'Quantity': _quantity,
      'OriginalPrice': _originalPrice,
      'DiscountedPrice': _discountedPrice,
      'Offer': _highestOffer,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuynowConfirmationPage(
          buyNowItem: buyNowItem,
        ),
      ),
    );
  }

  double _calculateDiscountedPrice() {
    // Calculate discounted price if offers exist
    if (widget.product['offers'] != null && widget.product['offers'].isNotEmpty) {
      var highestOffer = widget.product['offers'].reduce((current, next) {
        double currentOffer = double.tryParse(current['Offer_Percentage'].toString()) ?? 0;
        double nextOffer = double.tryParse(next['Offer_Percentage'].toString()) ?? 0;
        return (currentOffer > nextOffer) ? current : next;
      });

      double offerPercentage = double.tryParse(highestOffer['Offer_Percentage'].toString()) ?? 0;
      return _originalPrice * (1 - (offerPercentage / 100));
    }
    
    return _originalPrice;
  }

  Map<String, dynamic>? _getHighestOffer() {
    if (widget.product['offers'] != null && widget.product['offers'].isNotEmpty) {
      return widget.product['offers'].reduce((current, next) {
        double currentOffer = double.tryParse(current['Offer_Percentage'].toString()) ?? 0;
        double nextOffer = double.tryParse(next['Offer_Percentage'].toString()) ?? 0;
        return (currentOffer > nextOffer) ? current : next;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Now'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Image.network(
                        '$baseurl${widget.product['Image']}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(widget.product['Product_Name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show both original and discounted prices
                          RichText(
                            text: TextSpan(
                              children: [
                                // Original Price (if different from discounted)
                                if (_originalPrice != _discountedPrice)
                                  TextSpan(
                                    text: '\$${_originalPrice.toStringAsFixed(2)} ',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                // Discounted Price
                                TextSpan(
                                  text: '\$${_discountedPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: _originalPrice != _discountedPrice 
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
                          if (_highestOffer != null)
                            Text(
                              '${_highestOffer!['Offer_Percentage']}% OFF',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: _decrementQuantity,
                              ),
                              Text('$_quantity', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: _incrementQuantity,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  
                ],
              ),
            ),
          ),
          
          // Bottom Section with Total Price and Checkout
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
                      '\$${(_discountedPrice * _quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.green
                      )
                    ),
                  ],
                ),
                // Optional: Show total savings
                if (_originalPrice != _discountedPrice)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You saved \$${((_originalPrice - _discountedPrice) * _quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _proceedToConfirmation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Proceed to Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}