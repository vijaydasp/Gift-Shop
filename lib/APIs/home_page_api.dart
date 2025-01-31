import 'package:dio/dio.dart';
import 'package:gift_shop/ipaddress_page.dart';

Future<List<Map<String, dynamic>>> fetchProducts() async {
  try {
    final dio = Dio();
    final response = await dio.get('$baseurl/user/productswithoffers');

    if (response.statusCode == 200) {
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Expected List of products, but received: ${response.data.runtimeType}');
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching products: $error');
  }
}
