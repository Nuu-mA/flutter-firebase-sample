import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyInputFormState();
}

/// 入力フォーム用データクラス
///
class _FormData {
  String borrowOrLend = "borrow"; // 貸したのか借りたのか
  String user; // 借り貸しの相手の名前
  String stuff; // 何を貸し借りしたのか
  DateTime date = DateTime.now(); // 貸し借りの期限
}

class MyInputFormState extends State<InputFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  void _setLendOrRent(String value) {
    setState(() {
      _data.borrowOrLend = value;
    });
  }

  /// 日付の選択
  Future<DateTime> _selectTime(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: _data.date,
        firstDate: DateTime(_data.date.year - 2),
        lastDate: DateTime(_data.date.year + 2));
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference;
    _mainReference = Firestore.instance.collection('memo-sample').document();

    return Scaffold(
      appBar: AppBar(
        title: const Text('貸し借り入力'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // FireBaseに保存する
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _mainReference.setData({
                    'borrowOrLend': _data.borrowOrLend,
                    'user': _data.user,
                    'stuff': _data.stuff,
                    'date': _data.date
                  });
                  Navigator.pop(context);
                }
              }),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              RadioListTile(
                value: "borrow",
                groupValue: _data.borrowOrLend,
                title: Text("借りた"),
                onChanged: (String value) {
                  _setLendOrRent(value);
                },
              ),
              RadioListTile(
                  value: "lend",
                  groupValue: _data.borrowOrLend,
                  title: Text("貸した"),
                  onChanged: (String value) {
                    _setLendOrRent(value);
                  }),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: '相手の名前',
                  labelText: 'Name',
                ),
                onSaved: (String value) {
                  _data.user = value;
                },
                validator: (value) {
                  // TODO else文にしないとWARNING出ちゃう
                  if (value.isEmpty) {
                    return '名前は必須入力項目です';
                  }
                },
                initialValue: _data.user,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '借りたもの、貸したもの',
                  labelText: 'loan',
                ),
                onSaved: (String value) {
                  _data.stuff = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '借りたもの、貸したものは必須入力項目です';
                  }
                },
                initialValue: _data.stuff,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("締め切り日：${_data.date.toString().substring(0, 10)}"),
              ),
              RaisedButton(
                child: const Text("締め切り日変更"),
                onPressed: () {
                  _selectTime(context).then(
                    (time) {
                      if (time != null && time != _data.date) {
                        setState(
                          () {
                            _data.date = time;
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
