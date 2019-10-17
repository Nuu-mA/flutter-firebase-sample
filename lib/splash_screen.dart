import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseUser firebaseUser;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _confirmAuthentication(context, _auth, firebaseUser);
    return Scaffold(
      body: Center(
          child: FlatButton(
        child: const Text("Facebookログイン"),
        onPressed: () async => initiateFacebookLogin(context),
      )),
    );
  }
}

/// Facebook認証を実行する
void initiateFacebookLogin(BuildContext context) async {
  var facebookLogin = FacebookLogin();
  var permissions = ["email"];
  var facebookLoginResult =
      await facebookLogin.logIn(permissions);
  switch (facebookLoginResult.status) {
    case FacebookLoginStatus.error:
      print("Error");
      Fluttertoast.showToast(msg: "Facebookでのログインに失敗しました。");
      break;
    case FacebookLoginStatus.cancelledByUser:
      print("CancelledByUser");
      Fluttertoast.showToast(msg: "Facebookでのログインに失敗しました。");
      break;
    case FacebookLoginStatus.loggedIn:
      print("LoggedIn");
      // login済みならFirebase用認証情報を作成する
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final FirebaseUser _user =
          await _createFirebaseUesr(_auth, facebookLoginResult);
      // 認証の確認を行う
      _confirmAuthentication(context, _auth, _user);
      break;
  }
}

/// FirebaseAuthenticationUserを作成する
Future<FirebaseUser> _createFirebaseUesr(
    FirebaseAuth _auth, FacebookLoginResult _result) async {
  var facebookAccessToken = await _result.accessToken;
  final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: facebookAccessToken.token);
  final AuthResult authResult = await _auth.signInWithCredential(credential);
  return authResult.user;
}

/// ログイン情報を確認する
void _confirmAuthentication(
    BuildContext context, FirebaseAuth _auth, FirebaseUser firebaseUser) async {
  if (firebaseUser != null) {
    // ユーザー情報が取れればログイン済みなので画面遷移させる
    Navigator.pushReplacementNamed(
      context,
      "/list",
      arguments: {
        "firebaseUser": firebaseUser,
        "auth": _auth,
      },
    );
  } else {
    // ユーザー情報の取得が出来ていないなら未ログイン
    Fluttertoast.showToast(msg: "Firebaseとの接続に失敗しました。(新規ログイン)");
  }
}
