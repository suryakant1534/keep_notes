import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_notes/utils/background_task.dart' as background;
import 'package:keep_notes/utils/database_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _connectToFirebase();
    super.initState();
  }

  _connectToFirebase() async {
    try {
      await DatabaseHelper.initialize();

      await background.workmanager.initialize(
        background.callbackDispatcher,
        isInDebugMode: false,
      );

      if (mounted) {
        Get.offAllNamed("home");
      }
    } catch (e) {
      _showAlertDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            Image.asset("assets/KN.png", width: 150, height: 150),
            const Spacer(),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Connecting..",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            )
          ],
        ),
      ),
    );
  }

  _showAlertDialog(String e) {
    final AlertDialog dialog = AlertDialog(
      title: const Text(
        "Exception Occur",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      content: Text(
        e,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 15,
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            exit(1);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.red,
          child: const Text(
            "EXIT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
        ),
        MaterialButton(
          onPressed: () {
            Get.back();
            _connectToFirebase();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.blue,
          child: const Text(
            "RETRY",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }
}
