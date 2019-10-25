import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_firebase_sample/splash_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'input_form_wdiget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/list': (_) => List(),
        '/splash_screen': (BuildContext context) => SplashScreen(),
      },
    );
  }
}

class List extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyList();
}

class _MyList extends State<List> {
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    FirebaseUser _firebaseUser = args["firebaseUser"];
    final FirebaseAuth _auth = args["auth"];
    return Scaffold(
      appBar: AppBar(
        title: const Text("チャットリスト"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              print("login");
              showBasicDialog(context, _firebaseUser, _auth);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          // ログインしたユーザーIDからドキュメントを取得しにいく
          stream: Firestore.instance
              .collection('users')
              .document(_firebaseUser.uid)
              .collection("transaction")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return ListView.builder(
              // 'documents'がレコード単位のデータかも
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
              itemBuilder: (context, index) => _buildListItem(
                  context, snapshot.data.documents[index], _firebaseUser),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          print("新規作成ボタンを押しました");
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "/new"),
              builder: (BuildContext context) =>
                  InputFormWidget(null, _firebaseUser),
            ),
          );
        },
      ),
    );
  }

  /// ログインと新規登録
  void showBasicDialog(
      BuildContext context, FirebaseUser firebaseUser, FirebaseAuth _auth) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String email, password;
    if (firebaseUser.isAnonymous) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("ログイン/登録ダイアログ"),
          content: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.mail),
                    labelText: 'Email',
                  ),
                  onSaved: (String value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Emailは必須入力項目です';
                    }
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.vpn_key),
                    labelText: 'Password',
                  ),
                  onSaved: (String value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Passwordは必須入力項目です';
                    }
                    if (value.length < 6) {
                      return 'Passwordは6桁以上です';
                    }
                  },
                ),
              ],
            ),
          ),
          // ボタンの配置
          actions: <Widget>[
            FlatButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('登録'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _createUser(context, email, password, _auth);
                }
              },
            ),
            FlatButton(
              child: const Text('ログイン'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _signIn(context, email, password, _auth);
                }
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("確認ダイアログ"),
          content: Text(firebaseUser.displayName + " でログインしています。"),
          actions: <Widget>[
            FlatButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('ログアウト'),
              onPressed: () {
                _auth.signOut();
                FacebookLogin().logOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/splash_screen", (_) => false);
              },
            ),
          ],
        ),
      );
    }
  }

  void _signIn(BuildContext context, String email, String password,
      FirebaseAuth _auth) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(
          context, "/splash_screen", (_) => false);
    } catch (e) {
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました。");
    }
  }

  void _createUser(BuildContext context, String email, String password,
      FirebaseAuth _auth) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(
          context, "/splash_screen", (_) => false);
    } catch (e) {
      Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました。");
    }
  }

  /// リストアイテムWidget(一個一個のリスト単位のWidget)
  Widget _buildListItem(BuildContext context, DocumentSnapshot document,
      FirebaseUser firebaseUser) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              document['comment'],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: Text(
                document['user_name'],
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: FlatButton(
              child: const Text("編集",style: TextStyle(color: Colors.blueAccent),),
              onPressed: () {
                //編集ボタンの処理追加
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: "/edit"),
                    builder: (BuildContext context) =>
                        InputFormWidget(document, firebaseUser),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
