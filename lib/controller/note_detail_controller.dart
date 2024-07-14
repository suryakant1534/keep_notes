import 'package:keep_notes/utils/background_task.dart' as background;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';

class NoteDetailController extends GetxController {
  static NoteDetailController get to => Get.find<NoteDetailController>();

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
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    super.onInit();
  }

  Future<void> submit(Note note, bool isNew, int currentIndex) async {
    await _addNoteOnLocal(note, isNew, currentIndex);
    if (_noteListController.isLogin) {
      await background.createATask(
        taskName: background.insertTask,
        inputData: note.toMap(),
      );
    }
  }

  Future<void> _addNoteOnLocal(Note newNote, bool isNew, int index) async {
    if (isNew) {
      await _noteListController.databaseHelper.insertData(newNote);
    } else {
      _noteListController.removeNote(index);
      await _noteListController.databaseHelper.updateData(newNote);
    }
    _noteListController.addNote(newNote);
  }

  deleteNote(int index) async => _noteListController.deleteNote(index);

  void clearField() {
    titleController.clear();
    descriptionController.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
