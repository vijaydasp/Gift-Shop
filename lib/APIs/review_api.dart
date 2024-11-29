import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/models/review_model.dart';

final dio = Dio();

Future<ProductReview?> submitReview({
  required int productId,
  required int? username,
  required double rating,
  required String comment,
}) async {
  try {
    final response = await dio.post(
      '$baseurl/user/reviews',
      data: {
        'product_id': productId,
        'username': username,
        'rating': rating,
        'comment': comment,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Adjust based on your exact response structure
      var responseData = response.data['data'] ?? response.data;
      return ProductReview.fromJson(responseData);
    }
    return null;
  } catch (e) {
    print('Error submitting review: $e');
    return null;
  }
}

Future<List<ProductReview>> fetchProductReviews(int productId) async {
  try {
    final response = await dio.get(
      '$baseurl/user/reviews/$productId',
    );
    print(response.data);
    if (response.statusCode == 200) {
      // Check if the response data is a list or has a 'data' key with a list
      dynamic reviewsData = response.data['data'] ?? response.data;

      if (reviewsData is List) {
        return reviewsData
            .map<ProductReview>((reviewJson) => ProductReview.fromJson(reviewJson))
            .toList();
      } else {
        print('Unexpected response format: $reviewsData');
        return [];
      }
    }
    return [];
  } on DioException catch (e) {
    print('Error fetching reviews: ${e.response?.data ?? e.message}');
    return [];
  } catch (e) {
    print('Unexpected error fetching reviews: $e');
    return [];
  }
}
