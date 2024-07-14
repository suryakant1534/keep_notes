import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keep_notes/authentication/firebase_auth.dart';
import 'package:keep_notes/controller/bin_note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/database_helper.dart';
import 'package:keep_notes/utils/firebase_helper.dart';
import 'package:keep_notes/utils/background_task.dart' as background;

part 'initial_controller.dart';

class NoteListController extends GetxController {
  static NoteListController get to => Get.find<NoteListController>();

  final RxList<Note> _notes = RxList.empty(growable: true);
  final RxInt _normalIndex = 0.obs;
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final FirebaseAuthentication _auth = FirebaseAuthentication();
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  InitialController get _initialController => InitialController.to;

  bool get isLogin => _initialController.isLoggedIn;

  String get userName => _firebaseHelper.user?.displayName ?? "Guest";

  User? get user => _firebaseHelper.user;

  List<Note> get notes => List.from(_notes, growable: false);

  Future<void> _readDataLocal() async {
    final List<Map<String, dynamic>> data = await databaseHelper.readData();
    clearNote();
    for (final Map<String, dynamic> json in data) {
      addNote(Note.fromMapObj(json));
    }
  }

  Future<void> deleteNote(int index) async {
    final note = removeNote(index);
    await databaseHelper.deleteData(note: note);
    await databaseHelper.insertData(note, insertIntoBin: true);
    _initialController._binController.notes.add(note);
    if (isLogin) {
      await background.createATask(
        taskName: background.deleteTask,
        inputData: note.toMap(),
      );
    }
  }

  Note removeNote(int index) {
    final note = _notes.removeAt(index);
    if (note.priority == 2) {
      _normalIndex(_normalIndex.value - 1);
    }
    return note;
  }

  void addNote(Note note) {
    if (note.priority == 2) {
      _notes.insert(0, note);
      _normalIndex(_normalIndex.value + 1);
    } else {
      _notes.insert(_normalIndex.value, note);
    }
  }

  void clearNote() {
    _notes.clear();
    _normalIndex(0);
  }

  Future<User?> login() async {
    final user = await _auth.signInWithGoogle();
    await HapticFeedback.vibrate();
    return user?.user;
  }

  Future<void> logout() async {
    for (final sub in _initialController._subscriptions) {
      await sub.cancel();
    }
    _initialController._subscriptions.clear();
    await background.workmanager.cancelAll();
    await _auth.logout();
    await HapticFeedback.vibrate();
  }

  Future<void> syncNow() async {
    final notes = List<Note>.from(_notes, growable: false);
    final user = await login();
    if (user != null) {
      Map<String, dynamic> data = {};
      for (final note in notes) {
        List<String> noteValue = [];

        noteValue.add(background.startWithDate + note.dateTime);
        noteValue.add(background.startWithDescription + note.description);
        noteValue.add(background.startWithTitle + note.title);
        noteValue.add(background.startWithId + note.id.toString());
        noteValue.add(background.startWithPriority + note.priority.toString());

        data[note.firebaseId] = noteValue;
      }
      clearNote();
      databaseHelper.clearAllData();
      print(data.length);
      await background.createATask(
        taskName: background.insertBatch,
        inputData: data,
      );
    }
  }
}
