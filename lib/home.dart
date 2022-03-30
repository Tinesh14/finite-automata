import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'custom_search.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController _textFieldController = TextEditingController();

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  addData(String value) {
    firestoreInstance.collection("users").add({
      "word": value.toString(),
    }).then((val) => debugPrint("kita cek disini : ${val.id}"));
  }

  String codeDialog = "";
  String valueText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Welcome to the dictionary :)',
            ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add New Word to Dictionary'),
                  content: TextField(
                    onChanged: (value) {
                      setState(() {
                        valueText = value;
                      });
                    },
                    controller: _textFieldController,
                    decoration: const InputDecoration(hintText: "New Word"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      child: const Text('OK'),
                      onPressed: () {
                        codeDialog = valueText;
                        debugPrint("tes : $codeDialog");
                        firestoreInstance.collection("users").add({
                          "word": codeDialog,
                        }).whenComplete(() {
                          Navigator.pop(context);
                          _textFieldController.text = "";
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
