import 'package:dio/dio.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/ipaddress_page.dart';
import 'package:gift_shop/models/order_model.dart';

Future<List<Order>> fetchOrderHistory() async {
  final dio = Dio();

  try {
    final response = await dio.get('$baseurl/user/history/$userId/');
    
    if (response.statusCode == 200) {
      final data = response.data['order_history'] as List<dynamic>;
      
      return data.map((orderData) {
        return Order(
          orderId: 'Order #${orderData["OrderID"]}',
          date: DateTime.parse(orderData["Date"]),
          amount: orderData["Total_Amount"].toDouble(),
          status: orderData["Order_Status"],
          paymentStatus: orderData["Payment_Status"],
          deliveryId: orderData["DeliveryID"],
          orderItems: (orderData["OrderItems"] as List<dynamic>).map((item) {
            return OrderItem(
              productName: item["ProductName"],
              quantity: item["Quantity"],
              price: item["Price"].toDouble(),
              offerTitle: item["OfferTitle"],
            );
          }).toList(),
        );
      }).toList();
    } else {
      throw Exception('Failed to load order history');
    }
  } catch (e) {
    print('Error fetching order history: $e');
    rethrow;
  }
}