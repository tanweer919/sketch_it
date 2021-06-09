import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth _auth;
  GoogleSignIn googleSignIn;
  FirebaseAuthService() {
    _auth = FirebaseAuth.instance;
    googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
  }


  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    final UserCredential authResult =
    await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    return user;
  }

  Future getFirebaseUser() async {
    User currentUser = _auth.currentUser;
    return currentUser;
  }

  void logOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }
}