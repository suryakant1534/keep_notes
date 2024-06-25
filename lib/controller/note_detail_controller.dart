import 'package:keep_notes/utils/firebase_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/database_helper.dart';

class NoteDetailController extends GetxController {
  static NoteDetailController get to => Get.find<NoteDetailController>();

  late final DatabaseHelper databaseHelper;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final RxString _priorityValue = 'Low'.obs;
  final List<String> _priorities = List.from(['Low', 'High'], growable: false);
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  NoteListController get _noteListController => NoteListController.to;

  List<String> get priorities => _priorities;

  String get priorityValue => _priorityValue.value;

  set priorityValue(value) => _priorityValue(value);

  @override
  void onInit() {
    _initialized();
    super.onInit();
  }

  void _initialized() {
    databaseHelper = DatabaseHelper();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  Future<void> submit(Note note, bool isNew, [int? index]) async {
    if (_noteListController.isLogin) {
      if (await _noteListController.isInternetAvailable) {
        isNew
            ? _firebaseHelper.insert(note: note)
            : await _firebaseHelper.update(note);
      } else {
        // Todo:- store data when internet is available.
      }
    } else {
      await _addNoteOnLocalDatabase(note, isNew, index);
    }
  }

  _addNoteOnLocalDatabase(Note note, bool isNew, [int? index]) async {
    if (isNew) {
      await databaseHelper.insertData(note);
    } else {
      await databaseHelper.updateData(note);
      Note oldNote = NoteListController.to.notes[index!];
      NoteListController.to.removeNote(oldNote);
    }

    NoteListController.to.addNote(note);
  }

  Future<void> deleteNote(Note note) async {
    await _noteListController.deleteNote(note);
  }
}
