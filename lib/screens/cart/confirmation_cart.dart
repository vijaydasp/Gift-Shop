import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/provider/cartProvider.dart';
import 'package:gift_shop/screens/cart/payment_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newHouseController = TextEditingController();
  final TextEditingController _newCityController = TextEditingController();
  final TextEditingController _newDistrictController = TextEditingController();
  final TextEditingController _newPincodeController = TextEditingController();
  final TextEditingController _newPhoneNumberController =
      TextEditingController();

  String? _selectedAddress;
  String? _currentAddress;
  String? _city;
  String? _district;
  int? _pincode;
  int? _phoneNumber;
  String? _fullname;

  // New address details
  String? _newName;
  String? _newHouse;
  String? _newCity;
  String? _newDistrict;
  String? _newPincode;
  String? _newPhone;

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  Future<void> _loadCurrentAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAddress = prefs.getString('address');
      _city = prefs.getString('city');
      _district = prefs.getString('district');
      _pincode = prefs.getInt('pincode');
      _phoneNumber = prefs.getInt('phonenumber');
      _fullname = prefs.getString('fullname');
    });
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _newHouseController.dispose();
    _newCityController.dispose();
    _newDistrictController.dispose();
    _newPincodeController.dispose();
    _newPhoneNumberController.dispose();
    super.dispose();
  }

  void _showAddressForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _newHouseController,
                  decoration:
                      const InputDecoration(labelText: 'House Name/ Flat No.'),
                ),
                TextField(
                  controller: _newCityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: _newDistrictController,
                  decoration: const InputDecoration(labelText: 'District'),
                ),
                TextField(
                  controller: _newPincodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pincode'),
                ),
                TextField(
                  controller: _newPhoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_newNameController.text.isEmpty ||
                _newHouseController.text.isEmpty ||
                _newCityController.text.isEmpty ||
                _newDistrictController.text.isEmpty ||
                _newPincodeController.text.isEmpty ||
                _newPhoneNumberController.text.isEmpty) {
                  setState(() {
                    _selectedAddress = 'current';
                    });
                    }
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_validateNewAddress()) {
                  setState(() {
                    _newName = _newNameController.text;
                    _newHouse = _newHouseController.text;
                    _newCity = _newCityController.text;
                    _newDistrict = _newDistrictController.text;
                    _newPincode = _newPincodeController.text;
                    _newPhone = _newPhoneNumberController.text;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all fields correctly')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  bool _validateNewAddress() {
    return _newNameController.text.isNotEmpty &&
        _newHouseController.text.isNotEmpty &&
        _newCityController.text.isNotEmpty &&
        _newDistrictController.text.isNotEmpty &&
        _newPincodeController.text.isNotEmpty &&
        _newPhoneNumberController.text.isNotEmpty &&
        int.tryParse(_newPincodeController.text) != null &&
        int.tryParse(_newPhoneNumberController.text) != null;
  }

  bool get isNewAddressValid {
    if (_selectedAddress == null) return false;

    if (_selectedAddress == 'current') {
      return _fullname != null &&
          _currentAddress != null &&
          _city != null &&
          _district != null &&
          _pincode != null &&
          _phoneNumber != null;
    }

    if (_selectedAddress == 'new') {
      return _newName != null &&
          _newHouse != null &&
          _newCity != null &&
          _newDistrict != null &&
          _newPincode != null &&
          _newPhone != null;
    }

    return false;
  }

  void _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    Map<String, dynamic> orderAddress;
    if (_selectedAddress == 'current') {
      if (!(_fullname != null &&
          _currentAddress != null &&
          _city != null &&
          _district != null &&
          _pincode != null &&
          _phoneNumber != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Current address information is incomplete')),
        );
        return;
      }
      orderAddress = {
        'name': _fullname,
        'address': _currentAddress,
        'city': _city,
        'district': _district,
        'pincode': _pincode,
        'phone': _phoneNumber,
      };
    } else {
      if (!isNewAddressValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add new address details')),
        );
        return;
      }
      orderAddress = {
        'name': _newName,
        'address': _newHouse,
        'city': _newCity,
        'district': _newDistrict,
        'pincode': int.parse(_newPincode!),
        'phone': int.parse(_newPhone!),
      };
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cart;

    final order = {
      'delivery_details': orderAddress,
      'cart_items': cartItems,
      'total_Amount': cartProvider.totalPrice,
      'originalTotalAmount': cartItems.fold(
        0.0, 
        (sum, item) => sum + (item['OriginalPrice'] * item['Quantity'])
      ),
      'orderDate': DateTime.now().toIso8601String(),
    };

    print('Processing order: $order');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(order)),
    );

    // await placeOrderApi(order);

    // cartProvider.clearCart();

    // Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for your order!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Order Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartProvider.cart.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cart[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: Image.network(
                      '$baseurl${item['Image']}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['Product_Name']),
                    subtitle: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          // Original Price (if different)
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
                            text: '\$${item['DiscountedPrice'].toStringAsFixed(2)} x ${item['Quantity']}',
                            style: TextStyle(
                              color: item['OriginalPrice'] != item['DiscountedPrice'] 
                                ? Colors.green 
                                : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Offer Percentage (if applicable)
                          if (item['Offer'] != null)
                            TextSpan(
                              text: ' (${item['Offer']['Offer_Percentage']}% OFF)',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  // Original Total (if there are discounts)
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      double totalOriginalPrice = cartProvider.cart.fold(
                        0.0, 
                        (sum, item) => sum + (item['OriginalPrice'] * item['Quantity'])
                      );
                      
                      return totalOriginalPrice != cartProvider.totalPrice
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Original Total:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                '\$${totalOriginalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink();
                  },
                  ),
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  // Savings Calculation
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
                        : const SizedBox.shrink();
                    },
                  ),
                ]
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Delivery Address:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Current Address'),
                leading: Radio<String>(
                  value: 'current',
                  groupValue: _selectedAddress,
                  onChanged: (value) {
                    setState(() {
                      _selectedAddress = value;
                    });
                  },
                ),
                subtitle: _selectedAddress == 'current'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fullname != null ? 'Name: $_fullname' : ''),
                          Text(_currentAddress != null
                              ? 'House Name/ Flat No.: $_currentAddress'
                              : ''),
                          Text(_city != null ? 'City: $_city' : ''),
                          Text(_district != null ? 'District: $_district' : ''),
                          Text(_pincode != null ? 'Pincode: $_pincode' : ''),
                          Text(_phoneNumber != null
                              ? 'Phone Number: $_phoneNumber'
                              : ''),
                        ],
                      )
                    : null,
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('New Address'),
                    leading: Radio<String>(
                      value: 'new',
                      groupValue: _selectedAddress,
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value;
                        });
                        if (value == 'new' && _newName == null) {
                          _showAddressForm();
                        }
                      },
                    ),
                  ),
                  if (_selectedAddress == 'new' && _newName != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: $_newName'),
                          Text('House Name/ Flat No.: $_newHouse'),
                          Text('City: $_newCity'),
                          Text('District: $_newDistrict'),
                          Text('Pincode: $_newPincode'),
                          Text('Phone Number: $_newPhone'),
                          TextButton(
                            onPressed: _showAddressForm,
                            child: const Text('Edit Address'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: isNewAddressValid ? _placeOrder : null,
          child: const Text('Place Order'),
        ),
      ),
    );
  }
}
