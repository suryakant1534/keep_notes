import 'package:flutter/material.dart';

class CustomAppBar{
  static PreferredSizeWidget cusAppBar({required String title}) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
    );
  }
}
