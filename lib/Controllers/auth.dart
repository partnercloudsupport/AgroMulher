import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

abstract class BaseAuth {
  Future<FirebaseUser> handleSignInGoogle();
  Future<FirebaseUser> handleSignInFacebook();
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookSignIn = FacebookLogin();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> handleSignInGoogle() async{
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print("signed in " + user.displayName);
    return user;
  }

  Future<FirebaseUser> handleSignInFacebook() async{
    final FacebookLoginResult result = await _facebookSignIn.logInWithReadPermissions(['email']);

    FirebaseUser user = await _firebaseAuth.signInWithFacebook(
      accessToken: result.accessToken.token,
    );

    print("signed in " + user.displayName);
    return user;
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    user.email;
    return user?.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    user.sendEmailVerification();
    return user?.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user?.uid;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _facebookSignIn.logOut();
    return _firebaseAuth.signOut();
  }
}