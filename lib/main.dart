import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:keep_notes/screens/note_detail.dart';
import 'package:keep_notes/screens/note_list.dart';
import 'package:keep_notes/screens/splash_screen.dart';
import 'package:keep_notes/utils/initial_binding.dart';

void main() async {
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.deepPurple,
      statusBarColor: Colors.deepPurple,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      title: 'KeepNotes',
      routes: {
        "home": (context) => const NoteList(),
        "/": (context) => const SplashScreen(),
        "detail": (context) => const NoteDetail(),
      },
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.deepPurple,
            systemNavigationBarColor: Colors.deepPurple,
          ),
        ),
      ),
      initialRoute: "/",
    );
  }
}
