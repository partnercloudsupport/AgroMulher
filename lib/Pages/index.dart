import 'package:agro_mulher/Pages/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import '../Controllers/auth_provider.dart';
import '../Controllers/auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class IndexPage extends StatefulWidget {
  final BaseAuth auth;
  
  IndexPage({this.auth});

  @override
  State<StatefulWidget> createState() => new IndexPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class IndexPageState extends State<IndexPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = AuthProvider.of(context).auth;
    auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
          onSignedOut:  _signedOut,
        );
      case AuthStatus.signedIn:
        return Menu(
          onSignedOut: _signedOut,
        );
    }
    return null;
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}