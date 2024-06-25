part of 'note_list_controller.dart';

class InitialController extends GetxController {
  static InitialController get to => Get.find<InitialController>();
  final RxBool _isLoggedIn = false.obs;
  late final StreamSubscription<Future<bool>> _subscription;
  final RxBool _isInternetAvailable = false.obs;
  StreamSubscription<QuerySnapshot>? _subscriptionOfQuerySnapshot;
  StreamSubscription<QuerySnapshot>? _subscriptionOfBinNote;
  final RxList<Note> _notes = RxList.empty(growable: true);
  final RxList<Note> _binNotes = RxList.empty(growable: true);
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  late bool isFirstTimeCalled;

  bool get isLoggedIn => _isLoggedIn.value;

  bool get isInternetAvailable => _isInternetAvailable.value;

  @override
  void onInit() {
    isFirstTimeCalled = true;
    _notesListen();
    _changeUser();
    _checkConnectivity();
    super.onInit();
  }

  _notesListen() {
    _notes.listen((_) {
      NoteListController.to.clearNote();
      for (Note note in _) {
        NoteListController.to.addNote(note);
      }
    });

    _binNotes.listen((_) {
      BinNoteListController.to.notes = _binNotes;
    });
  }

  void _initializeSubscriptionOfQuerySnapshot() {
    _subscriptionOfQuerySnapshot = _firebaseHelper
        .getStreamOfQuerySnapshot(wantToUseFromBin: false)
        .listen((event) {
      final notes = <Note>[];
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in event.docs) {
        final json = document.data();
        final note = Note.fromMapObj(json);
        notes.add(note);
      }
      _notes(notes);
    });

    _subscriptionOfBinNote = _firebaseHelper
        .getStreamOfQuerySnapshot(wantToUseFromBin: true)
        .listen((event) {
      final notes = <Note>[];
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in event.docs) {
        final json = document.data();
        final note = Note.fromMapObj(json);
        notes.add(note);
      }
      _binNotes(notes);
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
          await NoteListController.to.databaseHelper.clearAllData();
        }
      } else {
        NoteListController.to.userImage = "assets/guest.jpg";
        _subscriptionOfQuerySnapshot?.cancel();
        _subscriptionOfBinNote?.cancel();
        NoteListController.to._readDataLocal();
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

  // Todo:- check here when try to app in background like when app is closed from recent task.
  @override
  void onClose() {
    _subscription.cancel();
    _subscriptionOfQuerySnapshot?.cancel();
    _subscriptionOfBinNote?.cancel();
    super.onClose();
  }
}
