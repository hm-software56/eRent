class Translations {
  Map translate = {'daxiong': 'daxiong'};
  String getlang;
  String lang;
  String lanngdefault = "English";
  List<String> listlang= ["English","Lao"];
  list(list_map, key) {
    if (list_map[key] == null) {
      return key;
    } else {
      return list_map[key];
    }
  }
}
