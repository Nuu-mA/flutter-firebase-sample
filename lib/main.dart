import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'input_form_wdiget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かしかりメモ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: List(),
    );
  }
}

class List extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyList();
}

class _MyList extends State<List> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('memo-sample').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData) return const Text('Loading...');
              return ListView.builder(
                // 'documents'がレコード単位のデータかも
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
              );
            }
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
                  builder: (BuildContext context) => InputFormWidget(null)
              ),
            );
          }
      ),
    );
  }

  /// リストアイテムWidget(一個一個のリスト単位のWidget)
  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return Card(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.android),
              title: Text("【 " + (document['borrowOrLend'] == "lend"?"貸": "借") +" 】"+ document['stuff']),
              subtitle: Text('期限 ： ' + document['date'].toDate().toString().substring(0,10) + "\n相手 ： " + document['user']),
            ),
            ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                        child: const Text("編集"),
                        onPressed: () {
                          print("編集ボタンを押しました");
                          //編集ボタンの処理追加
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                settings: const RouteSettings(name: "/edit"),
                                builder: (BuildContext context) => InputFormWidget(document)
                            ),
                          );
                        }
                    ),
                  ],
                )
            ),
          ]
      ),
    );
  }
}
