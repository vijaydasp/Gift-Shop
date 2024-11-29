class Order {
  final String orderId;
  final DateTime date;
  final double amount;
  final String status;
  final String paymentStatus;
  final int deliveryId;
  final List<OrderItem> orderItems;

  Order({
    required this.orderId,
    required this.date,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.deliveryId,
    required this.orderItems,
  });
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;
  final String? offerTitle;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.offerTitle,
  });
}