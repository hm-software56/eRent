import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translations {
  Map translate = {'daxiong': 'daxiong'};
  String getlang;
  String lang;
  String lanngdefault = "English";
  List<String> listlang= ["English","Lao"];
  Map langcode = {'English':'en', 'Lao':'la'};
  list(list_map, key) {
    if (list_map[key] == null) {
      return key;
    } else {
      return list_map[key];
    }
  }

  Future<Map> loadlang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getlang = await prefs.get('lang');
    String jsonContent =
        await rootBundle.loadString("locale/${getlang}.json");
       translate = json.decode(jsonContent);
     
  }
}
