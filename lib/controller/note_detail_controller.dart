import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/database_helper.dart';

class NoteDetailController extends GetxController {
  static NoteDetailController get to => Get.find<NoteDetailController>();

  late final DatabaseHelper helper;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final RxString _priorityValue = 'Low'.obs;
  final List<String> _priorities = List.from(['Low', 'High'], growable: false);

  List<String> get priorities => _priorities;

  String get priorityValue => _priorityValue.value;

  set priorityValue(value) => _priorityValue(value);

  @override
  void onInit() {
    _initialized();
    super.onInit();
  }

  void _initialized() {
    helper = DatabaseHelper();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  void submit(Note note, bool isNew, [int? index]) {
    if (isNew) {
      helper.insertData(note);
    } else {
      helper.updateData(note);
      Note oldNote = NoteListController.to.notes[index!];
      NoteListController.to.deleteNote(oldNote);
    }

    NoteListController.to.addNote(note);
  }

  void deleteNote(Note note) {
    helper.deleteData(note);
    NoteListController.to.deleteNote(note);
  }
}
