import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/check_network.dart';
import 'package:keep_notes/utils/database_helper.dart';
import 'package:keep_notes/utils/firebase_helper.dart';

class BinNoteListController extends GetxController {
  static BinNoteListController get to => Get.find<BinNoteListController>();
  final RxList<Note> _notes = RxList.from([], growable: true);
  final RxBool _isSelectAll = false.obs;
  final RxBool _isSelectActive = false.obs;
  final RxBool _isLoading = false.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final RxMap<String, Note> _selectedNote = RxMap<String, Note>();
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  Map<String, Note> get selectedNote => _selectedNote;

  bool get isLoading => _isLoading.value;

  bool get isSelectActive => _isSelectActive.value;

  bool get isSelectAll => _isSelectAll.value;

  bool get isLogin => NoteListController.to.isLogin;

  set isSelectAll(bool value) => _isSelectAll(value);

  set notes(List<Note> notes) => _notes(notes);

  List<Note> get notes => List.from(_notes, growable: false);

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
    if (NoteListController.to.isLogin) return;
    _isLoading(true);
    _notes.clear();
    for (Map<String, dynamic> jsonData
        in (await _databaseHelper.readData(true))) {
      _notes.add(Note.fromMapObj(jsonData));
    }
    _isLoading(false);
  }

  void get selectAll {
    if (_isSelectAll.value) {
      for (Note note in _notes) {
        _selectedNote[isLogin ? note.firebaseId! : note.id.toString()] = note;
      }
    } else {
      _selectedNote.clear();
    }
  }

  //todo:- check on change data when logged in.
  void get check {
    _isSelectAll(_selectedNote.length == _notes.length);
  }

  Future<void> deleteNotes([Note? note]) async {
    _isSelectActive(false);
    if (NoteListController.to.isLogin) {
      if (await CheckNetwork.isInternetAvailable()) {
        if (note != null) {
          await _firebaseHelper.delete(note: note, wantToDeleteFromBin: true);
        } else {
          _selectedNote.forEach((key, value) async {
            await deleteNotes(value);
          });
        }
      } else {
        //todo:- implement when internet is available then run delete documents.
      }
    } else {
      if (note != null) {
        await _databaseHelper.deleteData(note, true);
        _notes.remove(note);
      } else {
        if (selectedNote.length == 1) {
          selectedNote.forEach((key, value) async {
            await deleteNotes(value);
          });
        } else {
          final List<Note> notes = List.empty(growable: true);
          notes.addAll(selectedNote.values);
          await _databaseHelper.deleteData(null, true, notes);
          selectedNote.forEach((key, value) {
            _notes.remove(value);
          });
        }
      }
    }
  }

  Future<void> restoreData([Note? note]) async {
    _isSelectActive(false);
    if (NoteListController.to.isLogin) {
      if (await CheckNetwork.isInternetAvailable()) {
        await _firebaseHelper.restore(
          note: note,
          notes: _selectedNote.values.toList(),
        );
      } else {
        // ToDo:- when network is connect then apply this logkc.
      }
    } else {
      if (note != null) {
        await _databaseHelper.deleteData(note, true);
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
}
