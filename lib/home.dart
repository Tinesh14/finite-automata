// ignore_for_file: prefer_const_constructors

import 'dart:convert';

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

  Future<List<String>> getMarker() async {
    var snapshot = await firestoreInstance.collection('users').get();
    var listData = snapshot.docs.map((doc) => doc.data()).toList();
    List<String> listString = [];
    for (var e in listData) {
      listString.add(e['word']);
      // debugPrint("test datanya : ${jsonEncode(e)}, ${e['word']}");
    }
    return listString;
  }

  static getNextState(List<String> data, int m, int state, int x) {
    if ((state < m) && (x == data[state].codeUnits.elementAt(0))) {
      return state + 1;
    }

    for (var ns = state; ns > 0; ns--) {
      if (data[ns - 1].codeUnits.elementAt(0) == x) {
        for (var i = 0; i < ns - 1; i++) {
          if (data[i] != data[state - ns + 1 + i]) {
            break;
          }
          if (i == ns - 1) {
            return ns;
          }
        }
      }
    }
    return 0;
  }

  static void computeTF(List<String> data, int m, List<List<int>> tf) {
    for (var state = 0; state <= m; ++state) {
      for (var x = 0; x < 256; ++x) {
        tf[state][x] = getNextState(data, m, state, x);
      }
    }
  }

  static bool searchString(List<String> data, List<String> data1) {
    int m = data.length;
    int n = data1.length;

    bool result = false;
    var TF = List.generate(m + 1, (i) => List.filled(256, 0, growable: true));
    computeTF(data, m, TF);

    int state = 0;
    for (var i = 0; i < n; i++) {
      state = TF[state][data1[i].codeUnits.elementAt(0)];
      debugPrint("cek state value : $state, $i, $n, ${data1[i]}");
      if (state == m) {
        debugPrint(
            "Pattern found at index ${(i - m + 1)}"); //INDEX KE 12 GK MUNCUL
        result = true;
      }
    }

    return result;
    //debugPrint("nilai nya : $m, $n");
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
                delegate: CustomSearchDelegate((search, closeNotifier) {
                  var result = [];
                  List<String> resultString = [];
                  getMarker().then((value) => result = value).whenComplete(
                    () {
                      // for (var element in result) {
                      //   var temp = element.toString().toLowerCase();
                      //   var temp1 = search.toLowerCase();
                      //   List<String> pat = [];
                      //   List<String> searchText = [];
                      //   for (var i in temp1.runes) {
                      //     searchText.add(String.fromCharCode(i));
                      //   }
                      //   for (var rune in temp.runes) {
                      //     pat.add(String.fromCharCode(rune));
                      //   }
                      //   var resultBool = searchString(searchText, pat);

                      //   if (resultBool) {
                      //     resultString.add(element.toString());
                      //   }
                      // }
                      // widgetView = ListView.builder(
                      //   itemCount: resultString.length,
                      //   padding: const EdgeInsets.all(10),
                      //   itemBuilder: (context, index) {
                      //     return Text("index : ${resultString[index]}");
                      //   },
                      // );

                      // for (var element in resultString) {
                      //   debugPrint("hasil pencarian : $element");
                      // }
                    },
                  );
                  //debugPrint("cek datanya : ${result.length}");
                  return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (builder,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        // debugPrint("${streamSnapshot.data.docs.map((e) => null)}");
                        if (streamSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child:
                                CircularProgressIndicator(color: Colors.blue),
                          );
                        } else {
                          // debugPrint(
                          //     "cek data : ${jsonEncode(streamSnapshot.data)}");
                          var listData = streamSnapshot.data?.docs
                              .map((doc) => doc.data())
                              .toList();
                          List<String> listString = [];
                          for (var e in (listData ?? [])) {
                            listString.add(e['word']);
                            // debugPrint("test datanya : ${jsonEncode(e)}, ${e['word']}");
                          }
                          for (var element in listString) {
                            var temp = element.toString().toLowerCase();
                            var temp1 = search.toLowerCase();
                            List<String> pat = [];
                            List<String> searchText = [];
                            for (var i in temp1.runes) {
                              searchText.add(String.fromCharCode(i));
                            }
                            for (var rune in temp.runes) {
                              pat.add(String.fromCharCode(rune));
                            }
                            var resultBool = searchString(searchText, pat);

                            if (resultBool) {
                              resultString.add(element.toString());
                            }
                          }
                          return ListView.builder(
                            itemCount: resultString.length,
                            padding: const EdgeInsets.all(30),
                            itemBuilder: (context, index) {
                              return Text("index : ${resultString[index]}");
                            },
                          );
                        }
                      });
                  // ListView.builder(
                  //   itemCount: resultString.length,
                  //   padding: const EdgeInsets.all(10),
                  //   itemBuilder: (context, index) {
                  //     return Text("index : ${resultString[index]}");
                  //   },
                  // );
                }),
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
