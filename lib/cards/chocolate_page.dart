import 'package:flutter/material.dart';
import 'package:gift_shop/ipaddress_page.dart';
import 'package:gift_shop/screens/view_product.dart';

class ChocolatePage extends StatelessWidget {
  final List<Map<String, dynamic>> product;

  const ChocolatePage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    var chocolate = product.where((item) => item['category_name'] == 'Chocolates').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chocolate Products'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: chocolate.length,
          itemBuilder: (context, index) {
            var chocolates = chocolate[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: chocolates),
                  ),
                );
              },
              child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), 
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [

                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    child: Image.network(
                      '$baseurl${chocolates['Image']}',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      chocolates['Product_Name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Price: \$${chocolates['Price']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              )
            );
          },
        ),
      ),
    );
  }
}
