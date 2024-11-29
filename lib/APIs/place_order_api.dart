// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';

final dio = Dio();

Future<void> placeOrderApi(Map<String, Object> order) async {
  try {
    final response = await dio.post(
      '$baseurl/user/place-order/$userId/',
      data: order,
    );

    print(response.data);
    int? res = response.statusCode;
    print(res);

    if (res == 201) {
      print("Success");
    } else {
      print("Error");
    }
  } catch (e) {
    print('Error: $e');
    status = "Error occurred";
  }
}
