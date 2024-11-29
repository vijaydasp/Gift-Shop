import 'package:flutter/material.dart';

Widget categoryCard(String title, IconData icon, Widget page,context) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          // Navigate to the corresponding page when the card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 100,
            height: 80,
            child: Icon(icon, size: 40),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(title),
    ],
  );
}

  

  

  