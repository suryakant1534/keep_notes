import 'package:flutter/material.dart';

class CustomAppBar {
  static PreferredSizeWidget cusAppBar(
      {required String title, List<Widget>? actions}) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      actions: actions,
    );
  }
}
