class Translations {
  Map translate = {'daxiong': 'daxiong'};
  String getlang;
  String lang;
  String lanngdefault = "en";
  List<String> listlang= ["1","2"];
  list(list_map, key) {
    if (list_map[key] == null) {
      return key;
    } else {
      return list_map[key];
    }
  }
}
