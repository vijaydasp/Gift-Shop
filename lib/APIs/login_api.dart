// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseurl = "http://192.168.207.18:5000";
final dio = Dio();
String? status;
int? sessionData;
int? userId;
String? address;
String? city;
String? district;
int? pincode;
int? phonenumber;
String? fullname;
String? profileImage;

Future<void> loginRequest(String email, String password) async {
  print("login_api");
  try {
    final response = await dio.post('$baseurl/user/loginapi/', data: {
      'username': email,
      'password': password,
    });

    print(response.data);
    int? res = response.statusCode;
    print(res);

    status = response.data['message'] ?? 'failed';
    sessionData = response.data['login_id'];
    address = response.data['Address'];
    city = response.data['City'];
    district = response.data['District'];
    pincode = response.data['Pincode'];
    phonenumber = response.data['Phone_Number'];
    fullname = response.data['Full_Name'];
    userId = response.data['id'];
    profileImage = response.data['profileImage'];

    print(status);
    print(sessionData);

    if (res == 200 && status == 'success') {
      if (sessionData != null && address != null && city != null && district != null && pincode != null && phonenumber != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('session_data', sessionData!);
        await prefs.setInt('id', userId!);
        await prefs.setString('address', address!);
        await prefs.setString('city', city!);
        await prefs.setString('district', district!);
        await prefs.setInt('pincode', pincode!);
        await prefs.setInt('phonenumber', phonenumber!);
        await prefs.setString('fullname', fullname!);
        await prefs.setString('profileImage', profileImage!);
        print("Success");
      } else {
        print("Error: One or more values are null");
      }
    } else {
      print('Failed');
    }
  } catch (e) {
    print('Error: $e');
    status = "Error occurred";
  }
}
