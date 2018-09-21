class Translations {
  String lang = "en";
  list(list_map, key) {
    if (list_map[key] == null) {
      return key;
    } else {
      return list_map[key];
    }
  }
}
