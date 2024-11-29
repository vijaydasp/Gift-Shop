import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';

final dio = Dio();

Future<Map<String, dynamic>> callChatbotApi(String question) async {
  try {
    final requestData = {'question': question};

    final response = await dio.post(
      '$baseurl/api/chat-history/$userId/',
      data: requestData,
    );

    print(response.data);
    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to get chatbot response');
    }
  } catch (e) {
    throw Exception('Failed to get chatbot response: $e');
  }
}

Future<List<dynamic>> getChatbotApi() async {
  try {
    final response = await dio.get(
      '$baseurl/api/chat-history/$userId/',
    );
    print(response.data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to get chatbot history');
    }
  } catch (e) {
    throw Exception('Failed to get chatbot history: $e');
  }
}