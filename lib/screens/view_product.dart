import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gift_shop/APIs/login_api.dart';
import 'package:gift_shop/APIs/review_api.dart';
import 'package:gift_shop/models/review_model.dart';
import 'package:gift_shop/provider/cartProvider.dart';
import 'package:gift_shop/screens/cart/buynow_cartpage.dart';
import 'package:gift_shop/screens/cart/cart_page.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  List<ProductReview> _productReviews = [];

  @override
  void initState() {
    super.initState();
    _loadProductReviews();
  }

  // Method to load product reviews
  void _loadProductReviews() async {
    setState(() {});

    try {
      final reviews = await fetchProductReviews(widget.product['id']);
      setState(() {
        _productReviews = reviews;
      });
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reviews: $e')),
      );
    }
  }

  void _submitReview() async {
    if (_rating == 0.0 && _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating or comment')),
      );
      return;
    }

    try {
      final submittedReview = await submitReview(
          productId: widget.product['id'],
          username: userId,
          rating: _rating,
          comment: _reviewController.text);

      if (submittedReview != null) {
        setState(() {
          _productReviews.insert(0, submittedReview);
        });

        setState(() {
          _rating = 0.0;
          _reviewController.clear();
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  // Function to show reviews bottom sheet
  void _showReviewsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Initialize sorting criteria
        String sortBy = 'Name'; // Default sort option

        // Calculate average rating
        double averageRating = _productReviews.isEmpty
            ? 0.0
            : _productReviews
                    .map((review) => review.rating)
                    .reduce((a, b) => a + b) /
                _productReviews.length;

        // Sorting function
        void sortReviews() {
          if (sortBy == 'Name') {
            _productReviews.sort((a, b) => a.username.compareTo(b.username));
          } else if (sortBy == 'Rating') {
            _productReviews.sort((a, b) => b.rating.compareTo(a.rating));
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            // Sort reviews whenever sorting criteria changes
            sortReviews();

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Rating and Review Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Product Reviews',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${_productReviews.length} Reviews',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Sorting Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Average Rating Section
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              buildStarRating(averageRating),
                            ],
                          ),

                          // Sorting Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Sort Reviews By:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: sortBy,
                                  icon: const Icon(Icons.sort,
                                      color: Colors.grey),
                                  elevation: 16,
                                  underline: Container(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      sortBy = newValue!;
                                    });
                                  },
                                  items: <String>['Name', 'Rating']
                                      .map<DropdownMenuItem<String>>(
                                        (String value) =>
                                            DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),

                      // Reviews List
                      Expanded(
                        child: (_productReviews.isEmpty
                            ? const Center(
                                child: Text(
                                  'No reviews yet. Be the first to review!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _productReviews.length,
                                itemBuilder: (context, index) {
                                  final review = _productReviews[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: review
                                              .profileImage.isNotEmpty
                                          ? NetworkImage(
                                              '$baseurl${review.profileImage}')
                                          : null,
                                      child: review.profileImage.isEmpty
                                          ? Text(
                                              review.username[0].toUpperCase())
                                          : null,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review.username,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        buildStarRating(review.rating),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(review.comment),
                                        const SizedBox(height: 5),
                                        Text(
                                          review.dateTime != null
                                              ? _formatDateTime(
                                                  review.dateTime!)
                                              : 'Date not available',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method to format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget buildStarRating(double rating) {
    int fullStars = rating.floor(); // Get the number of full stars
    bool hasHalfStar =
        (rating - fullStars) >= 0.25 && (rating - fullStars) <= 0.75;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        // Full stars
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber),
        // Half star (if applicable)
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber),
        // Empty stars
        for (int i = 0; i < emptyStars; i++)
          const Icon(Icons.star_border, color: Colors.amber),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            NetworkImage('$baseurl${widget.product['Image']}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.product['Product_Name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Product Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Category: ${widget.product['category_name']}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Builder(
                      builder: (context) {
                        // Get the original price
                        double originalPrice =
                            double.parse(widget.product['Price'].toString());
                        double discountedPrice = originalPrice;
                        var highestOffer;

                        // Check if there are any offers
                        if (widget.product['offers'] != null &&
                            widget.product['offers'].isNotEmpty) {
                          // Find the highest percentage offer with robust parsing
                          highestOffer =
                              widget.product['offers'].reduce((current, next) {
                            double currentOffer = double.tryParse(
                                    current['Offer_Percentage'].toString()) ??
                                0;
                            double nextOffer = double.tryParse(
                                    next['Offer_Percentage'].toString()) ??
                                0;
                            return (currentOffer > nextOffer) ? current : next;
                          });

                          // Calculate discounted price
                          double offerPercentage = double.tryParse(
                                  highestOffer['Offer_Percentage']
                                      .toString()) ??
                              0;
                          discountedPrice =
                              originalPrice * (1 - (offerPercentage / 100));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Original Price (if different from discounted)
                            if (originalPrice != discountedPrice)
                              Text(
                                '\$${originalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),

                            // Discounted Price
                            Text(
                              '\$${discountedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: originalPrice != discountedPrice
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),

                            // Offer Details
                            if (widget.product['offers'] != null &&
                                widget.product['offers'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade100),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${highestOffer['Offer_Title']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${highestOffer['Offer_Description']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Discount: ${highestOffer['Offer_Percentage']}% off',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Valid: ${highestOffer['Start_date']} to ${highestOffer['End_date']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Product Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.product['Description'] ??
                          'No description available.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // Show the rating dialog
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          content: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Rate and Review",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: RatingBar.builder(
                                                    initialRating: _rating,
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemBuilder: (context, _) =>
                                                        const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      setState(() {
                                                        _rating = rating;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Center(
                                                  child: Text(
                                                    "Your Rating: ${_rating.toStringAsFixed(1)}",
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  controller: _reviewController,
                                                  maxLines: 5,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: "Write a Review",
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText:
                                                        "Share your experience...",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _rating = 0.0;
                                                  _reviewController.clear();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: _submitReview,
                                              child: const Text('Submit'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Text('Add Review'),
                            ),
                            TextButton(
                              onPressed: _showReviewsBottomSheet,
                              child: const Text('View Reviews'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // Bottom Buttons Section (Unchanged)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        bool isProductInCart =
                            cartProvider.isInCart(widget.product);

                        return ElevatedButton.icon(
                          onPressed: () {
                            if (isProductInCart) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartPage(),
                                ),
                              );
                            } else {
                              cartProvider.addToCart(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.product['Product_Name']} added to cart!',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: Text(
                            isProductInCart ? 'Go to Cart' : 'Add to Cart',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BuynowCartPage(product: widget.product),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Buy Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
