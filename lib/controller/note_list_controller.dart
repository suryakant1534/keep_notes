import 'package:get/get.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/utils/database_helper.dart';

class NoteListController extends GetxController {
  static NoteListController get to => Get.find<NoteListController>();

  final RxList<Note> _notes = <Note>[].obs;
  final RxInt _normalIndex = 0.obs;
  late final DatabaseHelper helper;
  final RxBool _isLoading = false.obs;

  List<Note> get notes => List.from(_notes, growable: false);

  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    _initialized();
    super.onInit();
  }

  void _initialized() async {
    _isLoading(true);
    helper = DatabaseHelper();

    final List<Map<String, dynamic>> data = await helper.readData();

    for (Map<String, dynamic> noteData in data) {
      final Note note = Note.fromMapObj(noteData);
      addNote(note);
    }

    _isLoading(false);
  }

  void deleteNote(Note note) {
    helper.deleteData(note);
    if (note.priority == 2) {
      _normalIndex(_normalIndex.value - 1);
    }
    _notes.remove(note);
  }

  void addNote(Note note) {
    if (note.priority == 2) {
      _notes.insert(0, note);
      _normalIndex(_normalIndex.value + 1);
      return;
    }
    _notes.insert(_normalIndex.value, note);
  }
}
