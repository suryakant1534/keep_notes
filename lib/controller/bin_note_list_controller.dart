import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/database_helper.dart';
import 'package:keep_notes/utils/background_task.dart' as background;

class BinNoteListController extends GetxController {
  static BinNoteListController get to => Get.find<BinNoteListController>();
  final RxList<Note> _notes = RxList.from([], growable: true);
  final RxBool _isSelectAll = false.obs;
  final RxBool _isSelectActive = false.obs;
  final RxBool _isLoading = false.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final RxMap<String, Note> _selectedNote = RxMap<String, Note>();

  Map<String, Note> get selectedNote => _selectedNote;

  bool get isLoading => _isLoading.value;

  bool get isSelectActive => _isSelectActive.value;

  bool get isSelectAll => _isSelectAll.value;

  bool get isLogin => NoteListController.to.isLogin;

  set isSelectAll(bool value) => _isSelectAll(value);

  set notes(List<Note> notes) => _notes(notes);

  List<Note> get notes => List.from(_notes, growable: true);

  void get clear {
    _isSelectActive(false);
    selectAll;
  }

  void changeSelectActive() {
    _isSelectActive(!isSelectActive);
    _isSelectAll(false);
    selectAll;
  }

  void changeSelectAll() {
    _isSelectAll(!isSelectAll);
    _selectedNote.clear();
    selectAll;
  }

  fetchData() async {
    _isLoading(true);
    _notes.clear();
    for (Map<String, dynamic> jsonData
        in (await _databaseHelper.readData(selectFromBin: true))) {
      _notes.add(Note.fromMapObj(jsonData));
    }
    _isLoading(false);
  }

  void get selectAll {
    if (_isSelectAll.value) {
      for (Note note in _notes) {
        _selectedNote[isLogin ? note.firebaseId : note.id.toString()] = note;
      }
    } else {
      _selectedNote.clear();
    }
  }

  void get check {
    _isSelectAll(_selectedNote.length == _notes.length);
  }

  Future<void> deleteNotes([Note? note]) async {
    _isSelectActive(false);
    await _deleteNotesFromLocal(note);
    if (isLogin) await _deleteNotesFromCloud(note);
  }

  _deleteNotesFromCloud([Note? note]) async {
    if (note != null) {
      _createATask(note, background.deleteIntoBinTask);
    } else {
      for (Note note in _selectedNote.values) {
        _createATask(note, background.deleteIntoBinTask);
      }
    }
  }

  _deleteNotesFromLocal([Note? note]) async {
    if (note != null) {
      await _databaseHelper.deleteData(note: note, deleteFromBin: true);
      _notes.remove(note);
    } else {
      if (selectedNote.length == 1) {
        selectedNote.forEach((key, value) async {
          await deleteNotes(value);
        });
      } else {
        final List<Note> notes = List.empty(growable: true);
        notes.addAll(selectedNote.values);
        await _databaseHelper.deleteData(deleteFromBin: true, notes: notes);
        selectedNote.forEach((key, value) {
          _notes.remove(value);
        });
      }
    }
  }

  Future<void> restoreData([Note? note]) async {
    _isSelectActive(false);
    await _restoreFromLocal(note);
    if (isLogin) await _restoreFromCould(note);
  }

  _restoreFromCould([Note? note]) async {
    if (note != null) {
      await _createATask(note, background.restoreTask);
    } else {
      for (Note note in _selectedNote.values) {
        await _createATask(note, background.restoreTask);
      }
    }
  }

  _createATask(Note note, String taskName) async {
    await background.createATask(
      taskName: taskName,
      inputData: note.toMap(),
    );
  }

  _restoreFromLocal([Note? note]) async {
    if (note != null) {
      await _databaseHelper.deleteData(note: note, deleteFromBin: true);
      await _databaseHelper.insertData(note);
      _notes.remove(note);
      NoteListController.to.addNote(note);
    } else {
      selectedNote.forEach((key, value) async {
        await restoreData(value);
      });
    }
  }
}
