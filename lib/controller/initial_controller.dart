part of 'note_list_controller.dart';

class InitialController extends GetxController {
  static InitialController get to => Get.find<InitialController>();
  final RxBool _isLoggedIn = false.obs;
  final List<StreamSubscription<QuerySnapshot>> _subscriptions =
      List.empty(growable: true);
  bool _isFirstTimeCalled = true;

  bool get isLoggedIn => _isLoggedIn.value;

  NoteListController get _listController => NoteListController.to;

  BinNoteListController get _binController => BinNoteListController.to;

  @override
  void onInit() {
    super.onInit();
    _changeUser();
  }

  void _changeUser() {
    _isLoggedIn(_listController._firebaseHelper.user != null);
    _listController._firebaseHelper.streamOfUser.listen(
      (user) async {
        _isLoggedIn(user != null);
        if (!_isFirstTimeCalled) {
          await _listController.databaseHelper.clearAllData();
        }

        _isFirstTimeCalled = false;
        _listController.clearNote();
        _binController.clearNote();

        await _listController._readDataLocal();
        await _binController.fetchData();

        if (user != null) {
          _subscriptions.add(_getSubscription());
          _subscriptions.add(_getSubscription(true));
        }
      },
    );
  }

  StreamSubscription<QuerySnapshot> _getSubscription([bool useForBin = false]) {
    return _listController._firebaseHelper
        .getStreamOfQuerySnapshot(wantToUseFromBin: useForBin)
        .listen(
      (QuerySnapshot<Map<String, dynamic>> event) async {
        final Map<String, Map<String, dynamic>> changesNotes = {};

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in event.docs) {
          final Map<String, dynamic> document = doc.data();
          changesNotes[document['firebaseId']] = document;
        }

        await _onChangesNote(changesNotes, useForBin);
      },
    );
  }

  _onChangesNote(
    Map<String, Map<String, dynamic>> changesNotes,
    bool useForBin,
  ) async {
    final Map<String, Map<String, dynamic>> oldNotes = {};
    final currentNotes =
        useForBin ? _binController.notes : _listController._notes;
    for (final note in currentNotes) {
      oldNotes[note.firebaseId] = note.toMap();
    }

    await _deleteOrUpdateNote(oldNotes, changesNotes, useForBin);

    await _addNote(oldNotes, changesNotes, useForBin);
  }

  Future<void> _deleteOrUpdateNote(
    Map<String, Map<String, dynamic>> oldNotes,
    Map<String, Map<String, dynamic>> changesNotes,
    bool useForBin,
  ) async {
    final List<String> todoUpdateNote = List.empty(growable: true);
    final List<String> todoDeleteNoteOnCurrent = List.empty(growable: true);
    final List<String> todoDeleteNoteOnChanges = List.empty(growable: true);
    final List<Note> todoUpdateNoteOnCloud = List.empty(growable: true);
    for (final firebaseId in oldNotes.keys) {
      if (changesNotes.containsKey(firebaseId)) {
        todoUpdateNote.add(firebaseId);
        todoDeleteNoteOnChanges.add(firebaseId);
      } else {
        final oldNote = Note.fromMapObj(oldNotes[firebaseId]!);
        final index = _getIndexOf(oldNote, useForBin);
        if (index != null) {
          useForBin
              ? _binController.notes.removeAt(index)
              : _listController.removeNote(index);
        }
        await _listController.databaseHelper.deleteData(
          note: oldNote,
          deleteFromBin: useForBin,
        );
      }
      todoDeleteNoteOnCurrent.add(firebaseId);
    }

    for (final firebaseId in todoUpdateNote) {
      final Map<String, dynamic> newNoteJson = changesNotes[firebaseId]!;
      final newNote = Note.fromMapObj(newNoteJson);
      final oldNote = Note.fromMapObj(oldNotes[firebaseId]!);
      newNote.id = oldNote.id;
      if (newNote != oldNote) {
        final index = _getIndexOf(oldNote, useForBin);
        if (index != null) {
          if (useForBin) {
            _binController.notes.removeAt(index);
            _binController.notes.insert(index, newNote);
          } else {
            _listController.removeNote(index);
            _listController.addNote(newNote);
          }

          await _listController.databaseHelper.updateData(
            newNote,
            updateOnBin: useForBin,
          );
        }
      }
      if (newNote.id != newNoteJson['id'] as int) {
        todoUpdateNoteOnCloud.add(newNote);
      }
    }

    for (final firebaseId in todoDeleteNoteOnChanges) {
      changesNotes.remove(firebaseId);
    }

    for (final firebaseId in todoDeleteNoteOnCurrent) {
      oldNotes.remove(firebaseId);
    }

    for (final note in todoUpdateNoteOnCloud) {
      await background.createATask(
        taskName:
            useForBin ? background.insertIntoBinTask : background.updateTask,
        inputData: note.toMap(),
      );
    }
  }

  int? _getIndexOf(Note oldNote, bool useForBin) {
    final notes = useForBin ? _binController.notes : _listController.notes;

    for (int i = 0; i < notes.length; i++) {
      if (notes[i] == oldNote) return i;
    }

    return null;
  }

  Future<void> _addNote(
    Map<String, Map<String, dynamic>> oldNotes,
    Map<String, Map<String, dynamic>> changesNotes,
    bool useForBin,
  ) async {
    final List<Note> todoAddNote = List.empty(growable: true);
    for (final firebaseId in changesNotes.keys) {
      if (!oldNotes.containsKey(firebaseId)) {
        final newNote = Note.fromMapObj(changesNotes[firebaseId]!);
        await _listController.databaseHelper.insertData(
          newNote,
          insertIntoBin: useForBin,
        );
        useForBin
            ? _binController.notes.add(newNote)
            : _listController.addNote(newNote);

        todoAddNote.add(newNote);
      }
    }

    for (final note in todoAddNote) {
      await background.createATask(
        taskName:
            useForBin ? background.insertIntoBinTask : background.updateTask,
        inputData: note.toMap(),
      );
    }
  }

  @override
  void dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
