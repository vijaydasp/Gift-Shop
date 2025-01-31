import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/home_page_api.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/cards/card_page.dart';
import 'package:gift_shop/cards/chocolate_page.dart';
import 'package:gift_shop/cards/decor_page.dart';
import 'package:gift_shop/cards/flower_page.dart';
import 'package:gift_shop/cards/hamper_page.dart';
import 'package:gift_shop/cards/jewellery_page.dart';
import 'package:gift_shop/drawer/complaint_page.dart';
import 'package:gift_shop/drawer/order_history_page.dart';
import 'package:gift_shop/drawer/profile_page.dart';
import 'package:gift_shop/drawer/wallet_page.dart';
import 'package:gift_shop/ipaddress_page.dart';
import 'package:gift_shop/screens/cart/cart_page.dart';
import 'package:gift_shop/screens/chat_bot_page.dart';
import 'package:gift_shop/screens/login_page.dart';
import 'package:gift_shop/screens/view_product.dart';
import 'package:gift_shop/widgets/home_page_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? fullnameprof;

class ShoppingHomePage extends StatefulWidget {
  const ShoppingHomePage({super.key});

  @override
  State<ShoppingHomePage> createState() => _ShoppingHomePageState();
}

class _ShoppingHomePageState extends State<ShoppingHomePage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> products = [];
  double minPrice = 0;
  double maxPrice = 10000;
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadFullName();
  }

  Future<void> loadFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullnameprof = prefs.getString('fullname');
    });
  }

  Future<void> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fetchedProducts = await fetchProducts();
      setState(() {
        fullnameprof = prefs.getString('fullname');
        products = fetchedProducts;
        print(fetchedProducts);
        filteredProducts = products;
      });
    } catch (error) {
      print("Error fetching products: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: SizedBox(
            width: 250,
            height: 40,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              ),
              onChanged: (query) {
                setState(() {
                  filteredProducts = products
                      .where((product) =>
                          (product['Product_Name']
                                  .toLowerCase()
                                  .contains(query.toLowerCase()) ||
                              product['category_name']
                                  .toLowerCase()
                                  .contains(query.toLowerCase())) &&
                          product['Price'] >= minPrice &&
                          product['Price'] <= maxPrice &&
                          (selectedCategories.isEmpty ||
                              selectedCategories
                                  .contains(product['category_name'])))
                      .toList();
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
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
      drawer: buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCategoryList(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'View all Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade300, Colors.purple.shade400],
                ),
              ),
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(253, 245, 242, 242)),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(product: product),
                              ),
                            );
                          },
                          child: buildProductCard(product),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          // Filter Button
          Positioned(
            bottom: 16,
            right: 16,
            child: Hero(
              tag: 'cart',
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: const Text('Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Price Range Slider
                                  const Text('Price Range',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  RangeSlider(
                                    min: 0,
                                    max: 10000,
                                    values: RangeValues(minPrice, maxPrice),
                                    onChanged: (RangeValues values) {
                                      setDialogState(() {
                                        minPrice = values.start;
                                        maxPrice = values.end;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Price: \$${minPrice.toStringAsFixed(0)} - \$${maxPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    filteredProducts = products
                                        .where((product) =>
                                            product['Price'] >= minPrice &&
                                            product['Price'] <= maxPrice &&
                                            (selectedCategories.isEmpty ||
                                                selectedCategories.contains(
                                                    product['category_name'])))
                                        .toList();
                                  });
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue),
                                child: const Text('Apply Filters'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 6, 3, 158),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.all(16),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.filter_list,
                  size: 30,
                ),
              ),
            ),
          ),

          // Chat Button
          Positioned(
            bottom: 80,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 6, 3, 158),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.all(16), // Icon color
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.chat,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              '$baseurl${product['Image']}',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['Product_Name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${product['Price']}',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            categoryCard('Flowers', Icons.local_florist,
                FlowerPage(product: products), context),
            categoryCard('Cards', Icons.card_giftcard,
                CardPage(product: products), context),
            categoryCard('Hampers', Icons.shopping_basket,
                HamperPage(product: products), context),
            categoryCard('Jewellery', Icons.watch,
                JewelleryPage(product: products), context),
            categoryCard('Chocolates', Icons.cake,
                ChocolatePage(product: products), context),
            categoryCard(
                'Decors', Icons.home, DecorPage(product: products), context),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    Future<void> editProfileImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        try {
          final formData = FormData.fromMap({
            'profileimage': await MultipartFile.fromFile(image.path,
                filename: 'profileimage.jpg')
          });

          final dio = Dio();
          final response = await dio.post(
            '$baseurl/user/update-profile-image/$sessionData/',
            data: formData,
          );
          print(response.data);
          if (response.statusCode == 200) {
            setState(() {
              profileImage = response.data['profileImage'];
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Profile image updated successfully')));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update profile image: $e')));
        }
      }
    }

    return SizedBox(
      width: 200,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
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
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              profileImage != null && profileImage!.isNotEmpty
                                  ? NetworkImage('$baseurl$profileImage')
                                  : AssetImage('assets/profile_default.jpeg')
                                      as ImageProvider,
                          backgroundColor: Colors.white,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: editProfileImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.edit,
                                  size: 20, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String?>(
                      valueListenable: ValueNotifier<String?>(fullnameprof),
                      builder: (context, value, child) {
                        return Text(
                          'Hi, ${value ?? 'Guest'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Wallet'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2_rounded),
              title: const Text('Complaints'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintPage(),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.feedback),
            //   title: const Text('Rate and Review'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const ReviewAndRatingPage(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryCheckboxes(StateSetter setDialogState) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Flowers'),
          value: selectedCategories.contains('Flowers'),
          onChanged: (bool? value) {
            setDialogState(() {
              if (value == true) {
                selectedCategories.add('Flowers');
              } else {
                selectedCategories.remove('Flowers');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Cards'),
          value: selectedCategories.contains('Cards'),
          onChanged: (bool? value) {
            setDialogState(() {
              if (value == true) {
                selectedCategories.add('Cards');
              } else {
                selectedCategories.remove('Cards');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Hampers'),
          value: selectedCategories.contains('Hampers'),
          onChanged: (bool? value) {
            setDialogState(() {
              if (value == true) {
                selectedCategories.add('Hampers');
              } else {
                selectedCategories.remove('Hampers');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Jewellery'),
          value: selectedCategories.contains('Jewellery'),
          onChanged: (bool? value) {
            setDialogState(() {
              if (value == true) {
                selectedCategories.add('Jewellery');
              } else {
                selectedCategories.remove('Jewellery');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Chocolates'),
          value: selectedCategories.contains('Chocolates'),
          onChanged: (bool? value) {
            setDialogState(() {
              if (value == true) {
                selectedCategories.add('Chocolates');
              } else {
                selectedCategories.remove('Chocolates');
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Decors'),
          value: selectedCategories.contains('Decors'),
          onChanged: (bool? value) {
            setDialogState(() {
              if (value == true) {
                selectedCategories.add('Decors');
              } else {
                selectedCategories.remove('Decors');
              }
            });
          },
        ),
      ],
    );
  }
}
