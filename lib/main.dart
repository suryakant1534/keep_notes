import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:keep_notes/firebase_options.dart';
import 'package:keep_notes/screens/bin_note_detail.dart';
import 'package:keep_notes/screens/bin_note_list.dart';
import 'package:keep_notes/screens/note_detail.dart';
import 'package:keep_notes/screens/note_list.dart';
import 'package:keep_notes/screens/splash_screen.dart';
import 'package:keep_notes/utils/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        'bin': (context) => const BinNoteList(),
        'bin_detail': (context) => BinNoteDetail(),
      },
      theme: ThemeData(
        useMaterial3: true,
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
