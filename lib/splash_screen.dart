import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _getUser(context);
    return Scaffold(
      body: Center(
        child: const Text("スプラッシュ画面"),
      ),
    );
  }
}

void _getUser(BuildContext context) async {
  FirebaseUser firebaseUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      await _auth.signInAnonymously();
      firebaseUser = await _auth.currentUser();
    }
    Navigator.pushReplacementNamed(
      context,
      "/list",
      arguments: {
        "firebaseUser": firebaseUser,
        "auth": _auth,
      },
    );
  } catch (e) {
    Fluttertoast.showToast(msg: "Firebaseとの接続に失敗しました。");
  }
}
