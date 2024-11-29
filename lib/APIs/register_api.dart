// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';

Future<void> registerUser(Map<String, dynamic> data,String profileImagePath) async {
  try {
    final response = await Dio().post(
      '$baseurl/user/register',
      data:FormData.fromMap({
        'First_Name': data['firstname'],
        'Last_Name': data['lastname'],
        'Address': data['address'],
        'City': data['city'],
        'District': data['district'],
        'Pincode': data['pincode'],
        'Phone_Number': data['phonenumber'],
        'username': data['username'],
        'Email': data['username'],
        'password': data['password'],
        'profileimage': await MultipartFile.fromFile(profileImagePath),
      })
    );
    print(response.data);
    int? res = response.statusCode;
    print(res);
    status = response.data['message'] ?? 'failed';
    print(status);
    
    if (res == 200 && status == 'success') {
      print('Registration Successful');
    } else {
      print('Registration failed');
    }
  } catch (e) {
    print(e);
  }
}
