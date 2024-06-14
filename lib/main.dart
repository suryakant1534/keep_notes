import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:keep_notes/screens/note_detail.dart';
import 'package:keep_notes/screens/note_list.dart';
import 'package:keep_notes/utils/initial_binding.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
        "/": (context) => const NoteList(),
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
