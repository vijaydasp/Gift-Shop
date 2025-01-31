import 'package:flutter/material.dart';
import 'package:gift_shop/ipaddress_page.dart';
import 'package:gift_shop/provider/cartProvider.dart';
import 'package:gift_shop/screens/login_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=>CartProvider()),
    ],
    child: MaterialApp(
      title: 'GIFT SHOP',
      debugShowCheckedModeBanner: false,
      home: IpAddressInputPage(),
    ),
    );
  }
}
