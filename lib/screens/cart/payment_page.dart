import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/place_order_api.dart';
import 'package:gift_shop/APIs/wallet_api.dart';
import 'package:gift_shop/provider/cartProvider.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, Object> order;

  const PaymentPage(this.order, {Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double? walletBalance;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    totalAmount = (widget.order['total_Amount'] as double?) ?? 0.0; // Cast to double
    callWalletApi();
  }

  Future<void> callWalletApi() async {
    try {
      var wallet = await getWallet();
      setState(() {
        walletBalance = wallet['wallet_balance']?.toDouble() ?? 0.0;
      });
    } catch (e) {
      print('Error fetching wallet data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.indigo.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: walletBalance == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Wallet Balance & Total Amount Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Wallet Balance",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "\$${walletBalance!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Divider(
                              height: 30,
                              thickness: 1,
                              color: Colors.grey,
                            ),
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "\$${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Pay Now Button
                    ElevatedButton(
                      onPressed: () async {
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        if (walletBalance! >= totalAmount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Payment Successful!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          await placeOrderApi(widget.order);
                          cartProvider.clearCart();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Insufficient Wallet Balance!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 80.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Colors.indigo.shade600,
                        elevation: 5,
                      ),
                      child: const Text(
                        "Pay Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
