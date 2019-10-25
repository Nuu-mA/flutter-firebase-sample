import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputFormWidget extends StatefulWidget {
  InputFormWidget(this.document, this.firebaseUser); // コンストラクタ
  final DocumentSnapshot document;
  final FirebaseUser firebaseUser;

  @override
  State<StatefulWidget> createState() => MyInputFormState();
}

/// 入力フォーム用データクラス
///
class _FormData {
  String comment; // コメント
  DateTime date = DateTime.now(); // コメント日時
}

class MyInputFormState extends State<InputFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference;
    _mainReference = Firestore.instance
        .collection('users')
        .document(widget.firebaseUser.uid)
        .collection("transaction") // テーブル名
        .document();
    //引数で渡した編集対象のデータがなければ新規作成なので、データの読み込みを行わない
    bool deleteFlg = false;
    if (widget.document != null) {
      //引数で渡したデータがあるかどうか
      if (_data.comment == null) {
        _data.comment = widget.document['comment'];
        _data.date = widget.document['createdat'].toDate();
      }
      _mainReference = Firestore.instance
          .collection('users')
          .document(widget.firebaseUser.uid)
          .collection("transaction") // テーブル名
          .document(widget.document.documentID);
      // 編集画面なので削除ボタン活性化フラグを立てる
      deleteFlg = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('コメント入力'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // FireBaseに保存する
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _mainReference.setData(
                  {
                    'comment': _data.comment,
                    'createdat': _data.date,
                    'user_name': widget.firebaseUser.displayName // Facebookのユーザー名をそのままぶち込む
                  },
                );
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            // 削除ボタンフラグをみる
            onPressed: !deleteFlg
                ? null
                : () {
                    // フラグが立っているなら編集対象を削除して画面を閉じる
                    _mainReference.delete();
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.create),
                  hintText: 'Add Comment',
                  labelText: 'Comment',
                ),
                maxLines: null,
                minLines: 1,
                onSaved: (String value) {
                  _data.comment = value;
                },
                validator: (value) {
                  // TODO else文にしないとWARNING出ちゃう
                  if (value.isEmpty) {
                    return '必須入力項目です';
                  }
                },
                initialValue: _data.comment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
