import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keep_notes/models/note.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:keep_notes/firebase_options.dart';

class FirebaseHelper {
  static Future<FirebaseHelper> get getObj async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return FirebaseHelper();
  }

  static FirebaseHelper? _instance;

  FirebaseHelper._createInstance();

  factory FirebaseHelper() => _instance ??= FirebaseHelper._createInstance();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  String? get _email => user?.email;

  String get _notesUrl => "/keep_notes/$_email/notes";

  String get _binNotesUrl => "/keep_notes/$_email/bin_notes";

  DocumentReference docRef(String firebaseId, [useForBin = false]) =>
      _reference(wantToUseBin: useForBin).doc(firebaseId);

  CollectionReference<Map<String, dynamic>> _reference(
          {bool wantToUseBin = false}) =>
      firestore.collection(wantToUseBin ? _binNotesUrl : _notesUrl);

  String getFirebaseId() => _reference().doc().id;

  Future<void> insert({
    required Note note,
    bool wantToInsertIntoBin = false,
  }) async {
    await _reference(wantToUseBin: wantToInsertIntoBin)
        .doc(note.firebaseId)
        .set(note.toMap());
  }

  Future<void> update(Note note, {bool wantToUpdateIntoBin = false}) async {
    await _reference(wantToUseBin: wantToUpdateIntoBin)
        .doc(note.firebaseId)
        .set(note.toMap());
  }

  Future<void> delete({
    required Note note,
    bool wantToDeleteFromBin = false,
  }) async {
    await _reference(wantToUseBin: wantToDeleteFromBin)
        .doc(note.firebaseId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamOfQuerySnapshot(
          {required bool wantToUseFromBin}) =>
      _reference(wantToUseBin: wantToUseFromBin).snapshots();

  Stream<User?> get streamOfUser => _auth.userChanges();

  Future<void> restore({Note? note, List<Note>? notes}) async {
    if (note != null) {
      await insert(note: note);
      await delete(note: note, wantToDeleteFromBin: true);
    } else if (notes != null) {
      for (Note note in notes) {
        await restore(note: note);
      }
    } else {
      throw "null value not allow on restore method.";
    }
  }
}
