import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/APIs/register_api.dart';
import 'package:gift_shop/screens/login_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName,
      _lastName,
      _address,
      _city,
      _district,
      _pincode,
      _phone,
      _email,
      _password,
      _confirmPassword;
  bool _isObscured = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _districts = [
    'Select District',
    "Alappuzha",
    "Ernakulam",
    "Idukki",
    "Kannur",
    "Kasaragod",
    "Kollam",
    "Kottayam",
    "Kozhikode",
    "Malappuram",
    "Palakkad",
    "Pathanamthitta",
    "Thiruvananthapuram",
    "Thrissur",
    "Wayanad"
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _profileImage = null;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile image')),
        );
        return;
      }
      Map<String, dynamic> data = {
      'firstname': _firstName,
      'lastname': _lastName,
      'address': _address,
      'city': _city,
      'district': _district,
      'pincode': _pincode,
      'phonenumber': _phone,
      'username': _email,
      'password': _password,
    };
      print(data);
      await registerUser(data, _profileImage!.path);

      if (status == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login successful"),
          backgroundColor: Colors.green,
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login failed"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter email and password"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registration Form',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 31, 91, 195),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: _profileImage == null
                          ? const Icon(Icons.person,
                              size: 50, color: Color.fromARGB(255, 59, 58, 58))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap:
                            _profileImage == null ? _pickImage : _removeImage,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(
                            _profileImage == null ? Icons.add : Icons.clear,
                            color: _profileImage == null
                                ? Colors.blue
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // First Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onSaved: (value) => _firstName = value,
                ),
                const SizedBox(height: 20),
                // Last Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onSaved: (value) => _lastName = value,
                ),
                const SizedBox(height: 20),
                // Address
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  onSaved: (value) => _address = value,
                ),
                const SizedBox(height: 20),
                // City
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                  onSaved: (value) => _city = value,
                ),
                const SizedBox(height: 20),
                // District Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'District',
                  ),
                  value: _district ?? _districts[0],
                  items: _districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _district = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value == _districts[0]) {
                      return 'Please select a district';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Pincode
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Pincode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.pin),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your pincode';
                    }
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    return null;
                  },
                  onSaved: (value) => _pincode = value,
                ),
                const SizedBox(height: 20),
                // Phone Number
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    setState(() {
                      _phone = phone.completeNumber;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.number.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value,
                ),
                const SizedBox(height: 20),
                // Password
                TextFormField(
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value,
                ),
                const SizedBox(height: 20),
                // Confirm Password
                TextFormField(
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    labelText: 'Re-enter Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (_password != null && value != _password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onSaved: (value) => _confirmPassword = value,
                ),
                const SizedBox(height: 30),
                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 31, 91, 195),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const SizedBox(
                    width: 150,
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
