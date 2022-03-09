// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
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
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.length > 3){
           var temp = "THIS IS A TEST TEXT";
     var temp1 = query;
     List<String>pat = [];
     List<String>searchText = [];
     for(var i in temp1.runes){
       searchText.add(String.fromCharCode(i));
     }
     for (var rune in temp.runes) {
       pat.add(String.fromCharCode(rune));
     }
     search(searchText, pat);
    }
    return Column();
  }

  static  getNextState(List<String>data, int m, int state, int x){
    if(state < m && x == data[state].codeUnits.first){
      return (state + 1);
    }
    int ns, i;
    for(ns = state; ns > 0; ns--){
      if(data[ns-1].codeUnits.first == x){
        for(i = 0; i < ns-1; i++){
          if(data[i] != data[state - ns + 1 + i]) {
            break;
          }
          if(i == ns-1){
            return ns;
          }
        }
      }
    }
    return 0;
  }

  static computeTF(List<String>data , int m, List<List<int>> tf){
    for(var state = 0; state < m; ++state){
      for(var x = 0; x < 256; ++x){
        tf[state][x] = getNextState(data, m, state, x);
        debugPrint("compute $state, $x, ${tf[state][x]}");
      }
    }
    return tf;
  }

  static void search(List<String> data, List<String> data1){
    int m = data.length;
    int n = data1.length;

    var TF = List.generate(m, (i) => List.filled(256, 0, growable: false));
    TF = computeTF(data, m, TF);

    int state = 0;
    for(var i = 0; i < n; i++){
      state = TF[state][data1[i].codeUnits.first]; //MASIH ERROR DISINI, BESOK SAMBUNG LAGI
      debugPrint("cek state value : $state");
      if(state == m){
        debugPrint("Pattern found at index ${(i-m+1)}");
      }else{
        debugPrint("$state, $m");
      }
    }
    debugPrint("nilai nya : $m, $n");
  }
}