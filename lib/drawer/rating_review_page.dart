import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewAndRatingPage extends StatefulWidget {
  const ReviewAndRatingPage({super.key});

  @override
  _ReviewAndRatingPageState createState() => _ReviewAndRatingPageState();
}

class _ReviewAndRatingPageState extends State<ReviewAndRatingPage> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review & Rating"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Color.fromRGBO(187, 222, 251, 1),
              ], // Add your desired gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rate and Review",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
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
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Write a Review",
                  border: OutlineInputBorder(),
                  hintText: "Share your experience...",
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Submission logic here
                    String review = _reviewController.text;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Review Submitted"),
                        content: Text(
                          "Rating: ${_rating.toStringAsFixed(1)}\nReview: $review",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

