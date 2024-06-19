import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/database_helper.dart';

class BinNoteListController extends GetxController {
  static BinNoteListController get to => Get.find<BinNoteListController>();
  final RxList<Note> _notes = RxList.from([], growable: true);
  final RxBool _isSelectAll = false.obs;
  final RxBool _isSelectActive = false.obs;
  final RxBool _isLoading = false.obs;
  final DatabaseHelper _helper = DatabaseHelper();
  final RxMap<int, Note> _selectedNote = RxMap<int, Note>();

  Map<int, Note> get selectedNote => _selectedNote;

  bool get isLoading => _isLoading.value;

  bool get isSelectActive => _isSelectActive.value;

  bool get isSelectAll => _isSelectAll.value;

  set isSelectAll(bool value) => _isSelectAll(value);

  List<Note> get notes => List.from(_notes, growable: false);

  void get clear {
    _isSelectActive(false);
    selectAll;
    return _notes.clear();
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
    for (Map<String, dynamic> jsonData in (await _helper.readData(true))) {
      _notes.add(Note.fromMapObj(jsonData));
    }
    _isLoading(false);
  }

  void get selectAll {
    if (_isSelectAll.value) {
      for (Note note in _notes) {
        _selectedNote[note.id] = note;
      }
    } else {
      _selectedNote.clear();
    }
  }

  void get check {
    _isSelectAll(_selectedNote.length == _notes.length);
  }

  deleteNotes([Note? note]) {
    _isSelectActive(false);
    if (note != null) {
      _helper.deleteData(note, true);
      _notes.remove(note);
    } else {
      if (selectedNote.length == 1) {
        selectedNote.forEach((key, value) {
          deleteNotes(value);
        });
      } else {
        final List<Note> notes = List.empty(growable: true);
        notes.addAll(selectedNote.values);
        _helper.deleteData(null, true, notes);
        selectedNote.forEach((key, value) {
          _notes.remove(value);
        });
      }
    }
  }

  restoreData([Note? note]) async {
    _isSelectActive(false);
    if (note != null) {
      await _helper.deleteData(note, true);
      await _helper.insertData(note);
      _notes.remove(note);
      NoteListController.to.addNote(note);
    } else {
      selectedNote.forEach((key, value) async {
        await restoreData(value);
      });
    }
  }
}
