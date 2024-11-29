import 'package:flutter/material.dart';
import 'package:gift_shop/models/order_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderId),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Color.fromRGBO(187, 222, 251, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard(
              title: 'Order ID',
              subtitle: order.orderId,
              icon: Icons.assignment,
            ),
            _buildDetailCard(
              title: 'Date',
              subtitle: order.date.toLocal().toString().split(' ')[0],
              icon: Icons.date_range,
            ),
            _buildStatusCard(),
            _buildDetailCard(
              title: 'Total Amount',
              subtitle: '\$${order.amount.toStringAsFixed(2)}',
              icon: Icons.money,
            ),
            _buildPaymentStatusCard(),
            const SizedBox(height: 20),
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            ...order.orderItems.map((item) => _buildOrderItemTile(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('Status'),
        subtitle: Text(order.status),
        leading: Icon(
          order.status == 'Completed'
              ? Icons.check_circle
              : Icons.access_time,
          color: order.status == 'Completed' ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('Payment Status'),
        subtitle: Text(order.paymentStatus),
        leading: Icon(
          order.paymentStatus == 'Paid'
              ? Icons.paid
              : Icons.payment,
          color: order.paymentStatus == 'Paid' ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item) {
    return ListTile(
      title: Text(item.productName),
      subtitle: Text('Quantity: ${item.quantity}'),
      trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
      leading: const Icon(Icons.shopping_cart),
      
    );
  }
}