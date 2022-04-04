// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  final firestoreInstance = FirebaseFirestore.instance;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var result = [];
    var resultString = [];
    getMarker().then((value) => result = value).whenComplete(
      () {
        if (query.length > 3) {
          for (var element in result) {
            var temp = searching(element.toString());
            if (temp) {
              resultString.add(element.toString());
            }
          }

          for (var element in resultString) {
            debugPrint("hasil pencarian : $element");
          }
        }
      },
    );
    //searching("THIS IS A TEST TEXT");
    return Container();
  }

  bool searching(String text) {
    var temp = text.toLowerCase();
    var temp1 = query.toLowerCase();
    List<String> pat = [];
    List<String> searchText = [];
    for (var i in temp1.runes) {
      searchText.add(String.fromCharCode(i));
    }
    for (var rune in temp.runes) {
      pat.add(String.fromCharCode(rune));
    }
    var result = search(searchText, pat);
    return result;
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

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
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

  static bool search(List<String> data, List<String> data1) {
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
}
