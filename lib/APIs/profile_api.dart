// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';

final dio = Dio();

Future<Map<String, dynamic>> getProfileData() async {
  try {
    final response = await dio.get('$baseurl/user/profile/$sessionData');
    print(response.data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load profile data');
    }
  } catch (e) {
    throw Exception('Failed to load profile data: $e');
  }
}

Future<void> updateProfileData(
    Map<String, dynamic> data) async {
  try {
    final response = await dio.put('$baseurl/user/profile/$sessionData', data: {
        'First_Name': data['firstname'],
        'Last_Name': data['lastname'],
        'Address': data['address'],
        'City': data['city'],
        'District': data['district'],
        'Pincode': data['pincode'],
        'Phone_Number': data['mobile_number'],
        'username': data['email'],
        'Email': data['email'],
        'password': data['password'],
    });
    print(response.data);
    int? res = response.statusCode;
    print(res);
    if (res == 200) {
      print("Success");
    } else {
      print('Failed');
    }
  } catch (e) {
    print('Error: $e');
    status = "Error occurred";
  }
}
