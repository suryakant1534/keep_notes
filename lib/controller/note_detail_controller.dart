import 'package:keep_notes/utils/background_task.dart' as background;
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
    await _addNoteOnLocalDatabase(note, isNew, index);
    if (_noteListController.isLogin) {
      await background.createATask(
        taskName: background.insertTask,
        inputData: note.toMap(),
      );
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
