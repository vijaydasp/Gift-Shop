import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/order_history_api.dart';
import 'package:gift_shop/drawer/order_details_page.dart';
import 'package:gift_shop/models/order_model.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Order> orderList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final orders = await fetchOrderHistory();
      
      setState(() {
        orderList = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load order history';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                )
              : orderList.isEmpty
                  ? const Center(
                      child: Text(
                        'No order history found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        final order = orderList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              order.status == 'Completed' ? Icons.check_circle : Icons.access_time,
                              color: order.status == 'Completed' ? Colors.green : Colors.orange,
                              size: 32,
                            ),
                            title: Text(
                              order.orderId,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${order.date.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Chip(
                              label: Text(
                                order.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: order.status == 'Completed'
                                  ? Colors.green
                                  : order.status == 'Shipped'
                                      ? Colors.blue
                                      : order.status == 'Pending'
                                          ? Colors.orange
                                          : Colors.grey,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsPage(order: order),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}