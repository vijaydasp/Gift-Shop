import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/profile_api.dart';
import 'package:gift_shop/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    callApi();
  }

  Future<void> callApi() async {
    try {
      var profileData = await getProfileData();
      setState(() {
        _firstnameController.text = profileData['First_Name'] ?? '';
        _lastnameController.text = profileData['Last_Name'] ?? '';
        _mobileController.text = profileData['Phone_Number']?.toString() ?? '';
        _emailController.text = profileData['Email'] ?? '';
        _addressController.text = profileData['Address'] ?? '';
        _cityController.text = profileData['City'] ?? '';
        _districtController.text = profileData['District'] ?? '';
        _pincodeController.text = profileData['Pincode']?.toString() ?? '';
      });
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  void _onSave() async {
  Map<String, dynamic> updatedProfile = {
    'firstname': _firstnameController.text,
    'lastname': _lastnameController.text,
    'email': _emailController.text,
    'mobile_number': _mobileController.text,
    'address': _addressController.text,
    'city': _cityController.text,
    'district': _districtController.text,
    'pincode': _pincodeController.text,
  };

  try {
    await updateProfileData(updatedProfile);
    // Update the fullnameprof variable
    fullnameprof = "${_firstnameController.text} ${_lastnameController.text}";
    
    // Save to SharedPreferences to persist the updated name
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullname', fullnameprof!);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      
      // Refresh the home page to update the drawer
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShoppingHomePage(),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }
}



Future<void> loadFullName() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    fullnameprof = prefs.getString('fullname');
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField('First Name', _firstnameController),
            _buildTextField('Last Name', _lastnameController),
            _buildTextField('Email', _emailController),
            _buildTextField('Mobile Number', _mobileController),
            _buildTextField('Address', _addressController),
            _buildTextField('City', _cityController),
            _buildTextField('District', _districtController),
            _buildTextField('Pincode', _pincodeController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}
