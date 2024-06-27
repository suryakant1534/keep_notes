import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_notes/authentication/firebase_auth.dart';
import 'package:keep_notes/controller/bin_note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/check_network.dart';
import 'package:keep_notes/utils/database_helper.dart';
import 'package:keep_notes/utils/firebase_helper.dart';

part 'initial_controller.dart';

class NoteListController extends GetxController {
  static NoteListController get to => Get.find<NoteListController>();

  final RxList<Note> _notes = <Note>[].obs;
  final RxInt _normalIndex = 0.obs;
  late final DatabaseHelper databaseHelper;
  final RxBool _isLoading = false.obs;
  final FirebaseAuthentication _auth = FirebaseAuthentication();
  final RxString _userImage = "assets/guest.jpg".obs;
  final RxBool _isFailedLogin = false.obs;
  final RxString _errorMessage = "".obs;
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  InitialController get _initialController => InitialController.to;

  String get errorMessage => _errorMessage.value;

  bool get isFailedLogin => _isFailedLogin.value;

  Future<bool> get isInternetAvailable async =>
      await CheckNetwork.isInternetAvailable();

  bool get isLogin => _initialController.isLoggedIn;

  String get userName =>
      _firebaseHelper.user?.displayName.toString() ?? "Guest";

  String get userImage => _userImage.value;

  set userImage(String userImage) => _userImage(userImage);

  List<Note> get notes => List.from(_notes, growable: false);

  bool get isLoading => _isLoading.value;

  @override
  void onInit() async {
    Get.put(InitialController());
    databaseHelper = DatabaseHelper();
    super.onInit();
  }

  _readDataLocal() async {
    clearNote();
    final jsonData = await databaseHelper.readData();
    for (var json in jsonData) {
      addNote(Note.fromMapObj(json));
    }
  }

  Future<void> deleteNote(Note note) async {
    if (isLogin) {
      if (await isInternetAvailable) {
        await _firebaseHelper.insert(note: note, wantToInsertIntoBin: true);
        await _firebaseHelper.delete(note: note);
      } else {
        // todo:- apple logic when data is not on and try to delete.
      }
    } else {
      await databaseHelper.deleteData(note);
      removeNote(note);
    }
  }

  void removeNote(Note note) {
    _notes.remove(note);
    if (note.priority == 2) {
      _normalIndex(_normalIndex.value - 1);
    }
  }

  void addNote(Note note) async {
    if (note.priority == 2) {
      _notes.insert(0, note);
      _normalIndex(_normalIndex.value + 1);
      return;
    }
    _notes.insert(_normalIndex.value, note);
  }

  login() async {
    try {
      final user = await _auth.signInWithGoogle();
      _isFailedLogin(false);
      return user;
    } catch (e) {
      _isFailedLogin(true);
      _errorMessage(e.toString());
    }
  }

  logout() async {
    await _auth.logout();
  }

  void clearNote() {
    _notes.clear();
    _normalIndex(0);
  }

  Future<void> syncNow(List<Note> notes) async {
    if (!isLogin) return;
    if (await CheckNetwork.isInternetAvailable()) {
      for (final Note note in notes) {
        await _firebaseHelper.insert(note: note);
      }
    } else {
      //todo:- when network is available then work on there data to sync.
    }
  }
}
