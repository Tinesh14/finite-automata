// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'custom_search.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController userInputHangul = TextEditingController();
  TextEditingController userInputRomaji = TextEditingController();
  TextEditingController userInputWord = TextEditingController();
  bool indoToKorea = false;

  // addData(String value) {
  //   firestoreInstance.collection("users").add(
  //     {
  //       "word": value.toString(),
  //     },
  //   ).then(
  //     (val) => debugPrint("kita cek disini : ${val.id}"),
  //   );
  // }

  // Future<List<String>> getMarker() async {
  //   var snapshot = await firestoreInstance.collection('users').get();
  //   var listData = snapshot.docs.map((doc) => doc.data()).toList();
  //   List<String> listString = [];
  //   for (var e in listData) {
  //     listString.add(e['word']);
  //     // debugPrint("test datanya : ${jsonEncode(e)}, ${e['word']}");
  //   }
  //   return listString;
  // }

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

  static Map searchString(
      List<String> data, List<String> data1, BuildContext context) {
    final stopWatch = Stopwatch();
    stopWatch.start();
    int m = data.length;
    int n = data1.length;

    Map result = {
      'bool': false,
      'timeExecution': 0,
    };
    var TF = List.generate(m + 1, (i) => List.filled(256, 0, growable: true));
    computeTF(data, m, TF);

    int state = 0;
    int secondsStr = 0;
    bool checking = false;
    for (var i = 0; i < n; i++) {
      state = TF[state][data1[i].codeUnits.elementAt(0)];
      debugPrint("cek state value : $state, $i, $n, ${data1[i]}");
      if (state == m) {
        debugPrint("Pattern found at index ${(i - m + 1)}");
        if (stopWatch.isRunning) {
          stopWatch.stop();
          secondsStr += stopWatch.elapsed.inMilliseconds;
          debugPrint("waktu stopwatch ${stopWatch.elapsed.inMilliseconds}");
        }
        checking = true;
      }
    }
    result = {
      'bool': checking,
      'timeExecution': secondsStr,
    };

    return result;
    //debugPrint("nilai nya : $m, $n");
  }

  String valueText = "";

  radioDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Container(
                  //   margin:
                  //       const EdgeInsets.only(top: 24, right: 24, bottom: 10),
                  //   width: 25,
                  //   height: 25,
                  //   decoration: const BoxDecoration(
                  //       shape: BoxShape.circle, color: Colors.orange),
                  //   child: InkWell(
                  //     onTap: () {
                  //       Navigator.pop(context);
                  //     },
                  //     child: const Center(
                  //       child: Icon(
                  //         Icons.close,
                  //         color: Colors.white,
                  //         size: 15.0,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              ListTile(
                minVerticalPadding: 0,
                title: const Text("Indo - Korea"),
                trailing: Radio(
                  activeColor: Colors.blue,
                  value: 0,
                  groupValue: -1,
                  onChanged: (value) {
                    setState(
                      () {
                        indoToKorea = true;
                      },
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.grey,
              ),
              ListTile(
                minVerticalPadding: 0,
                title: const Text("Korea - Indo"),
                trailing: Radio(
                  activeColor: Colors.blue,
                  value: 0,
                  groupValue: -1,
                  onChanged: (value) {
                    setState(
                      () {
                        indoToKorea = false;
                      },
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              var resultTimeExecution = 0;
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  (search, closeNotifier) {
                    List<dynamic> resultString = [];
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
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.blue),
                          );
                        } else {
                          // debugPrint(
                          //     "cek data : ${jsonEncode(streamSnapshot.data)}");
                          var listData = streamSnapshot.data?.docs
                              .map((doc) => doc.data())
                              .toList();
                          List<dynamic> listString = [];
                          for (var e in (listData ?? [])) {
                            listString.add(e);
                            // debugPrint("test datanya : ${jsonEncode(e)}, ${e['word']}");
                          }
                          for (var element in listString) {
                            var temp = indoToKorea
                                ? element['word'].toString().toLowerCase()
                                : element['romaji']
                                    .toString()
                                    .toLowerCase(); // cek indo - korea / korea - indo
                            var temp1 = search.toLowerCase();
                            List<String> pat = [];
                            List<String> searchText = [];
                            for (var i in temp1.runes) {
                              searchText.add(String.fromCharCode(i));
                            }
                            for (var rune in temp.runes) {
                              pat.add(String.fromCharCode(rune));
                            }
                            var resultMap =
                                searchString(searchText, pat, context);
                            var resultBool = resultMap['bool'] as bool;
                            if (resultMap['timeExecution']
                                .toString()
                                .isNotEmpty) {
                              resultTimeExecution +=
                                  resultMap['timeExecution'] as int;
                              debugPrint("cek : $resultTimeExecution");
                            }
                            if (resultBool) {
                              resultString.add(element);
                            }
                          }
                          if (resultString.isNotEmpty) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (resultTimeExecution != null)
                                    Center(
                                      child: Text(
                                        "Waktu yg dibutuhkan : $resultTimeExecution ms",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: resultString.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Card(
                                        elevation: 8,
                                        shadowColor: Colors.blue,
                                        margin: const EdgeInsets.all(20),
                                        shape: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.white),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              resultString[index]['word'] ?? "",
                                              //"word",
                                              style: TextStyle(
                                                fontSize:
                                                    !indoToKorea ? 18 : 14,
                                                fontWeight: !indoToKorea
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              resultString[index]['hangul'] ??
                                                  "",
                                              // "hangul",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                //fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              resultString[index]['romaji'] ??
                                                  "",
                                              // "romaji",
                                              style: TextStyle(
                                                fontSize: indoToKorea ? 18 : 14,
                                                fontWeight: indoToKorea
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      );
                                      //Text("index : ${resultString[index]}");
                                    },
                                  )
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child:
                                  Lottie.asset('assets/no-data-animation.json'),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              );
              radioDialog();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Image.asset(
                'assets/cover.png',
                height: 500,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ScaffoldMessenger(
                child: Builder(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.transparent,
                    body: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: GestureDetector(
                        onTap: () {},
                        child: AlertDialog(
                          content: SingleChildScrollView(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Positioned(
                                  right: -40.0,
                                  top: -40.0,
                                  child: InkResponse(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const CircleAvatar(
                                      child: Icon(Icons.close),
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                                Form(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: userInputHangul,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                              labelText: 'Hangul'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: userInputRomaji,
                                          decoration: const InputDecoration(
                                              labelText: 'Romaji'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: userInputWord,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                              labelText: 'Indo'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.blue),
                                          child: const Text("Submit"),
                                          onPressed: () {
                                            if (userInputHangul.text.isNotEmpty &&
                                                userInputRomaji
                                                    .text.isNotEmpty &&
                                                userInputWord.text.isNotEmpty) {
                                              firestoreInstance
                                                  .collection("users")
                                                  .add(
                                                {
                                                  "hangul":
                                                      userInputHangul.text,
                                                  "romaji":
                                                      userInputRomaji.text,
                                                  "word": userInputWord.text,
                                                },
                                              ).whenComplete(
                                                () {
                                                  Navigator.pop(context);
                                                  userInputHangul.text = "";
                                                  userInputRomaji.text = "";
                                                  userInputWord.text = "";
                                                },
                                              );
                                            } else if (userInputHangul
                                                .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  elevation: 6.0,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                    'Hangul harus di isi',
                                                  ),
                                                ),
                                              );
                                            } else if (userInputRomaji
                                                .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  elevation: 6.0,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                    'Romaji harus di isi',
                                                  ),
                                                ),
                                              );
                                            } else if (userInputWord
                                                .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  elevation: 6.0,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                    'Indo harus di isi',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
