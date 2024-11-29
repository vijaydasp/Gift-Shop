import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';

final dio = Dio();

Future<Map<String, dynamic>> getWallet() async {
  try {
    final response = await dio.get('$baseurl/user/walletview/$userId');
    print(response.data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load wallet data');
    }
  } catch (e) {
    throw Exception('Failed to load wallet data: $e');
  }
}

Future<bool> topUpWallet(double amount) async {
  try {
    final response = await dio.post(
      '$baseurl/user/topup/$userId/',
      data: {"amount": amount}
    );

    print(response.data);
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Top-up successful");
      return true;
    } else {
      print("Top-up failed");
      return false;
    }
  } catch (e) {
    print('Error during top-up: $e');
    return false;
  }
}