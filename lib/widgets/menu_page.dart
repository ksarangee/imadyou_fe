import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class MenuPage extends StatelessWidget {
  final MenuItem item;

  const MenuPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(item.imagePath, height: 200),
        const SizedBox(height: 70),
        Text(
          item.title,
          style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF484848)),
        ),
      ],
    );
  }
}
