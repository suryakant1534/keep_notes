import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    await logout();
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication authentication =
            await account.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          await _firestore
              .collection("users")
              .doc(userCredential.user!.uid)
              .set({
            "name": user.displayName,
            "email": user.email,
            "photo_url": user.photoURL,
            "uid": user.uid,
          });
        }

        return userCredential;
      } else {
        throw "Please choose one account of google.";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future logout() async {
    await _auth.signOut();
    final isLogged = await _googleSignIn.isSignedIn();
    if (isLogged) await _googleSignIn.signOut();
  }
}
