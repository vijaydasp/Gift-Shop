import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';

Future<Map<String, dynamic>> submitComplaint(String complaint) async {
  try {
    final dio = Dio();

    final response =
        await dio.post('$baseurl/shop/add-complaint/$userId/', data: {
      "Complaint": complaint,
      "USERLID" : userId,
    });
    print(response.data);
    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to submit complaint');
    }
  } catch (e) {
    throw Exception('API Error: $e');
  }
}

Future<Map<String, dynamic>> fetchComplaints() async {
  try {
    final Response response = await dio.get('$baseurl/shop/get-complaint/$userId/');
    print(response.data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(
          'Failed to fetch complaints. Status code: ${response.statusCode}');
    }
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
          'Server error: ${e.response?.statusCode}, ${e.response?.data}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}
