import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keep_notes/models/note.dart';

class FirebaseHelper {
  static FirebaseHelper? _instance;

  FirebaseHelper._createInstance();

  factory FirebaseHelper() => _instance ??= FirebaseHelper._createInstance();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  String? get _email => user?.email;

  String get _notesUrl => "/keep_notes/$_email/notes";

  String get _binNotesUrl => "/keep_notes/$_email/bin_notes";

  CollectionReference<Map<String, dynamic>> _reference(
          {bool wantToUseBin = false}) =>
      _firestore.collection(wantToUseBin ? _binNotesUrl : _notesUrl);

  String _firebaseId(bool wantToUseBin) =>
      _reference(wantToUseBin: wantToUseBin).doc().id;

  Future<void> insert({
    required Note note,
    bool wantToInsertIntoBin = false,
  }) async {
    note.firebaseId = _firebaseId(wantToInsertIntoBin);
    await _reference(wantToUseBin: wantToInsertIntoBin)
        .doc(note.firebaseId)
        .set(note.toMap());
  }

  Future<void> update(Note note) async {
    await _reference().doc(note.firebaseId).set(note.toMap());
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
      await delete(note: note, wantToDeleteFromBin: true);
      await insert(note: note);
    } else if (notes != null) {
      for (Note note in notes) {
        await restore(note: note);
      }
    } else {
      throw "null value not allow on restore method.";
    }
  }
}
