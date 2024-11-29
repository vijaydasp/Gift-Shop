import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/screens/cart/payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuynowConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> buyNowItem;

  const BuynowConfirmationPage({super.key, required this.buyNowItem});

  @override
  _BuynowConfirmationPageState createState() => _BuynowConfirmationPageState();
}

class _BuynowConfirmationPageState extends State<BuynowConfirmationPage> {
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

  void _proceedToPayment() {
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

    // Prepare order details for single item (Buy Now)
    final order = {
      'delivery_details': orderAddress,
      'cart_items': [widget.buyNowItem],
      'total_Amount': _calculateTotalPrice(),
      'originalTotalAmount': _calculateOriginalPrice(),
      'orderDate': DateTime.now().toIso8601String(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(order)),
    );
  }

  double _calculateTotalPrice() {
    return double.parse(widget.buyNowItem['DiscountedPrice'].toString()) *
        widget.buyNowItem['Quantity'];
  }

  double _calculateOriginalPrice() {
    return double.parse(widget.buyNowItem['OriginalPrice'].toString()) *
        widget.buyNowItem['Quantity'];
  }

  @override
  Widget build(BuildContext context) {
    final double discountedPrice =
        double.parse(widget.buyNowItem['DiscountedPrice'].toString());
    final int quantity = widget.buyNowItem['Quantity'];
    final highestOffer = widget.buyNowItem['Offer'];
    final double originalPrice =
        double.parse(widget.buyNowItem['OriginalPrice'].toString());

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
            Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Image.network(
                  '$baseurl${widget.buyNowItem['Image']}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(widget.buyNowItem['Product_Name']),
                subtitle: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      // Original Price (if different)
                      if (originalPrice != discountedPrice)
                        TextSpan(
                          text: '\$${originalPrice.toStringAsFixed(2)} ',
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      // Discounted Price
                      TextSpan(
                        text:
                            '\$${discountedPrice.toStringAsFixed(2)} x $quantity',
                        style: TextStyle(
                          color: originalPrice != discountedPrice
                              ? Colors.green
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Offer Percentage (if applicable)
                      if (highestOffer != null)
                        TextSpan(
                          text: ' (${highestOffer['Offer_Percentage']}% OFF)',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(children: [
                // Original Total (if there are discounts)
                originalPrice != discountedPrice
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
                            '\$${(originalPrice * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
                      '\$${(discountedPrice * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                if (originalPrice != discountedPrice)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You saved \$${((originalPrice - discountedPrice) * quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ]),
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
                            Text(_currentAddress != null
                                ? 'House Name/ Flat No.: $_currentAddress'
                                : ''),
                            Text(_city != null ? 'City: $_city' : ''),
                            Text(_district != null
                                ? 'District: $_district'
                                : ''),
                            Text(_pincode != null ? 'Pincode: $_pincode' : ''),
                            Text(_phoneNumber != null
                                ? 'Phone Number: $_phoneNumber'
                                : ''),
                          ],
                        ))
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
          onPressed: isNewAddressValid ? _proceedToPayment : null,
          child: const Text('Place Order'),
        ),
      ),
    );
  }
}
