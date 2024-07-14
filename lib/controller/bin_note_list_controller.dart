import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/background_task.dart' as background;

class BinNoteListController extends GetxController {
  static BinNoteListController get to => Get.find<BinNoteListController>();
  static const selectForBin = true;

  final RxList<Note> _notes = RxList<Note>.empty(growable: true);
  final RxSet<int> _selectedNote = RxSet<int>();
  final RxBool _isSelectActive = false.obs;

  List<Note> get notes => _notes;

  bool get isSelectAll => _selectedNote.length == _notes.length;

  NoteListController get _listController => NoteListController.to;

  bool getIsSelectNote(int index) => _selectedNote.contains(index);

  bool get isSelectActive => _isSelectActive.value;

  bool get showFloatingActionButton => _selectedNote.isNotEmpty;

  void clearNote() => _notes.clear();

  void onChangeCheckBoxValue(int index) {
    _selectedNote.contains(index)
        ? _selectedNote.remove(index)
        : _selectedNote.add(index);
  }

  void selectAllOrNot(bool value) {
    _selectedNote.clear();
    if (value) {
      for (int i = 0; i < _notes.length; i++) {
        _selectedNote.add(i);
      }
    }
  }

  void changeSelectActive([bool isDispose = false]) {
    _selectedNote.clear();
    isDispose ? _isSelectActive(false) : _isSelectActive(!isSelectActive);
  }

  Future<void> fetchData() async {
    final data = await _listController.databaseHelper
        .readData(selectFromBin: selectForBin);
    _notes.clear();
    for (final Map<String, dynamic> json in data) {
      _notes.add(Note.fromMapObj(json));
    }
  }

  Future<void> deleteNote(int index) async {
    final note = _notes.removeAt(index);
    await _listController.databaseHelper.deleteData(
      note: note,
      deleteFromBin: selectForBin,
    );
    if (_listController.isLogin) await _createATaskForDelete(note);
  }

  Future<Map<String, dynamic>> _getSelectedData([bool canStore = false]) async {
    final notes = List<Note>.empty(growable: true);
    for (final index in _selectedNote) {
      final note = _notes[index];
      notes.add(note);
      await _listController.databaseHelper.deleteData(
        note: note,
        deleteFromBin: true,
      );
      if (canStore) {
        await _listController.databaseHelper.insertData(note);
        _listController.addNote(note);
      }
    }
    _selectedNote.clear();
    final data = <String, dynamic>{};

    for (final note in notes) {
      _notes.remove(note);
      final firebaseId = note.firebaseId;
      List<String> noteValue = [];

      noteValue.add(background.startWithPriority + note.priority.toString());
      noteValue.add(background.startWithId + note.id.toString());
      noteValue.add(background.startWithTitle + note.title);
      noteValue.add(background.startWithDescription + note.description);
      noteValue.add(background.startWithDate + note.dateTime);

      data[firebaseId] = noteValue;
    }
    notes.clear();
    return data;
  }

  Future<void> deleteSelectedNote() async {
    final data = await _getSelectedData();
    if (_listController.isLogin) {
      await _createABatchTask(background.deleteBatch, data);
    }
    changeSelectActive(true);
  }

  Future<void> restoreNote(int index) async {
    final note = _notes.removeAt(index);
    await _listController.databaseHelper.deleteData(
      note: note,
      deleteFromBin: selectForBin,
    );
    await _listController.databaseHelper.insertData(note);
    _listController.addNote(note);
    if (_listController.isLogin) await _createATaskForRestore(note);
  }

  Future<void> restoreSelectedNote() async {
    final data = await _getSelectedData(true);
    if (_listController.isLogin) {
      await _createABatchTask(background.restoreBatch, data);
    }
    changeSelectActive(true);
  }

  Future<void> _createATaskForDelete(Note note) async {
    await background.createATask(
      taskName: background.deleteIntoBinTask,
      inputData: note.toMap(),
    );
  }

  Future<void> _createATaskForRestore(Note note) async {
    await background.createATask(
      taskName: background.restoreTask,
      inputData: note.toMap(),
    );
  }

  Future<void> _createABatchTask(
    String taskName,
    Map<String, dynamic> data,
  ) async =>
      await background.createATask(taskName: taskName, inputData: data);
}
