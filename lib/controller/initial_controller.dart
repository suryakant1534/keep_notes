part of 'note_list_controller.dart';

class InitialController extends GetxController {
  static InitialController get to => Get.find<InitialController>();
  final RxBool _isLoggedIn = false.obs;
  late final StreamSubscription<Future<bool>> _subscription;
  final RxBool _isInternetAvailable = false.obs;
  StreamSubscription<QuerySnapshot>? _subscriptionOfQuerySnapshot;
  StreamSubscription<QuerySnapshot>? _subscriptionOfBinNote;
  final Map<String, dynamic> _oldNotesList = {};
  final Map<String, dynamic> _oldBinNotesList = {};
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late bool isFirstTimeCalled;

  bool get isLoggedIn => _isLoggedIn.value;

  bool get isInternetAvailable => _isInternetAvailable.value;

  NoteListController get _noteController => NoteListController.to;

  BinNoteListController get _binNoteController => BinNoteListController.to;

  @override
  void onInit() {
    isFirstTimeCalled = true;
    _changeUser();
    _checkConnectivity();
    super.onInit();
  }

  // todo load this method with isolate with communicator logic.
  _onNoteListChanges(Map<String, dynamic> changesNotes) async {
    for (final note in _noteController.notes) {
      _oldNotesList[note.firebaseId] = note.toMap();
    }
    const useForBin = false;
    await _addOrUpdateNoteWhenCloudDataChanges(
      changesNotes: changesNotes,
      oldNotes: _oldNotesList,
      useForBin: useForBin,
    );

    _whenDeletesOnCloudNotes(
      changesNotes: changesNotes,
      oldNotes: _oldNotesList,
      useForBin: useForBin,
    );

    _oldNotesList.clear();
  }

  _onBinNoteListChanges(Map<String, dynamic> changesNotes) async {
    for (final note in _binNoteController.notes) {
      _oldBinNotesList[note.firebaseId] = note.toMap();
    }
    const useForBin = true;
    await _addOrUpdateNoteWhenCloudDataChanges(
      changesNotes: changesNotes,
      oldNotes: _oldBinNotesList,
      useForBin: useForBin,
    );

    await _whenDeletesOnCloudNotes(
      changesNotes: changesNotes,
      oldNotes: _oldBinNotesList,
      useForBin: useForBin,
    );

    _oldBinNotesList.clear();
  }

  _whenDeletesOnCloudNotes({
    required Map<String, dynamic> changesNotes,
    required Map<String, dynamic> oldNotes,
    required bool useForBin,
  }) async {
    for (final firebaseId in oldNotes.keys) {
      if (!changesNotes.containsKey(firebaseId)) {
        final oldNote = Note.fromMapObj(oldNotes[firebaseId]);
        await _databaseHelper.deleteData(
            note: oldNote, deleteFromBin: useForBin);
        final index = _getIndexOf(oldNote, useForBin);
        if (index != null) {
          useForBin
              ? _binNoteController.notes.removeAt(index)
              : _noteController.removeNote(null, index);
        }
      }
    }
  }

  _addOrUpdateNoteWhenCloudDataChanges({
    required Map<String, dynamic> changesNotes,
    required Map<String, dynamic> oldNotes,
    required bool useForBin,
  }) async {
    for (final firebaseId in changesNotes.keys) {
      final newNote = Note.fromMapObj(changesNotes[firebaseId]);
      if (oldNotes.containsKey(firebaseId)) {
        final oldNote = Note.fromMapObj(oldNotes[firebaseId]);
        if (oldNote != newNote) {
          await _databaseHelper.updateData(newNote, updateOnBin: useForBin);

          final currentNote = Note.fromMapObj(oldNotes[firebaseId]);
          final index = _getIndexOf(currentNote, useForBin);
          if (index != null) {
            if (useForBin) {
              _binNoteController.notes.removeAt(index);
              _binNoteController.notes[index] = newNote;
            } else {
              _noteController.removeNote(null, index);
              _noteController.addNote(newNote);
            }
          }
        } else {
          if (oldNote.id != newNote.id) {
            await _databaseHelper.insertData(newNote, insertIntoBin: useForBin);
            final currentNote = Note.fromMapObj(oldNotes[firebaseId]);
            final index = _getIndexOf(currentNote, useForBin);
            if (index != null) {
              if (useForBin) {
                _binNoteController.notes.removeAt(index);
                _binNoteController.notes[index] = newNote;
              } else {
                _noteController.removeNote(null, index);
                _noteController.addNote(newNote);
              }
            }
            await background.createATask(
              taskName: useForBin
                  ? background.insertIntoBinTask
                  : background.updateTask,
              inputData: newNote.toMap(),
            );
          }
        }
      } else {
        final currentNotes =
            useForBin ? _binNoteController.notes : _noteController.notes;
        for (int i = 0; i < currentNotes.length; i++) {
          final note = currentNotes[i];
          if (note == newNote) {
            if (note.firebaseId != newNote.firebaseId) {
              await _databaseHelper.updateData(newNote, updateOnBin: useForBin);

              if (useForBin) {
                _binNoteController.notes.removeAt(i);
                _binNoteController.notes[i] = newNote;
              } else {
                _noteController.removeNote(null, i);
                _noteController.addNote(newNote);
              }
            }

            //todo:- for on changes id.
          } else {
            await _databaseHelper.insertData(newNote, insertIntoBin: useForBin);
            useForBin
                ? _binNoteController.notes.add(newNote)
                : _noteController.addNote(newNote);
            await background.createATask(
              taskName: useForBin
                  ? background.insertIntoBinTask
                  : background.updateTask,
              inputData: newNote.toMap(),
            );
          }
        }
      }
    }
  }

  int? _getIndexOf(Note note, [bool wantToBin = false]) {
    final currentNotes =
        wantToBin ? _binNoteController.notes : _noteController.notes;

    for (int i = 0; i < currentNotes.length; i++) {
      if (currentNotes[i] == note) return i;
    }

    return null;
  }

  void _initializeSubscriptionOfQuerySnapshot() {
    _subscriptionOfQuerySnapshot = _firebaseHelper
        .getStreamOfQuerySnapshot(wantToUseFromBin: false)
        .listen((event) {
      final notes = <String, dynamic>{};
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in event.docs) {
        final json = document.data();
        notes[json['firebaseId']] = json;
      }
      _onNoteListChanges(notes);
    });

    _subscriptionOfBinNote = _firebaseHelper
        .getStreamOfQuerySnapshot(wantToUseFromBin: true)
        .listen((event) {
      final notes = <String, dynamic>{};
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in event.docs) {
        final json = document.data();
        notes[json['firebaseId']] = json;
      }
      _onBinNoteListChanges(notes);
    });
  }

  void _changeUser() {
    _isLoggedIn(_firebaseHelper.user != null);
    _firebaseHelper.streamOfUser.listen((user) async {
      _isLoggedIn(user != null);
      NoteListController.to.clearNote();
      if (user != null) {
        NoteListController.to.userImage = user.photoURL.toString();
        _initializeSubscriptionOfQuerySnapshot();
        if (!isFirstTimeCalled) {
          await _databaseHelper.clearAllData();
          _noteController.clearNote();
        }
      } else {
        background.workmanager.cancelAll();
        NoteListController.to.userImage = "assets/guest.jpg";
        _subscriptionOfQuerySnapshot?.cancel();
        _subscriptionOfBinNote?.cancel();
        if (!isFirstTimeCalled) {
          await _databaseHelper.clearAllData();
          _noteController.clearNote();
        }
        _noteController.readDataLocal();
      }

      isFirstTimeCalled = false;
    });
  }

  void _checkConnectivity() async {
    final isInternetAvailable = await CheckNetwork.isInternetAvailable();
    _isInternetAvailable(isInternetAvailable);
    if (_isInternetAvailable.isFalse) _showSnackBar();

    _subscription = Stream.periodic(const Duration(seconds: 5), (_) {
      return CheckNetwork.isInternetAvailable();
    }).listen((futureValue) async {
      final isInternetAvailable = await futureValue;
      if (_isInternetAvailable.value != isInternetAvailable) {
        _isInternetAvailable(isInternetAvailable);
        _showSnackBar();
      } else {
        _isInternetAvailable(isInternetAvailable);
      }
    });
  }

  void _showSnackBar() {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: _isInternetAvailable.value ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
      messageText: Text(
        _isInternetAvailable.value
            ? "Internet is Connected.."
            : "Internet is Disconnected..",
        style: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }

  // todo: create background task for when data manipulated on cloud then data will manipulate on local. like delete insert update.
  @override
  void onClose() {
    _subscription.cancel();
    _subscriptionOfQuerySnapshot?.cancel();
    _subscriptionOfBinNote?.cancel();
    super.onClose();
  }
}
