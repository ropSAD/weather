import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather.dart';

// избранные города (хранятся на телефоне)
class FavRepository {
  static const String key = 'favs';

  Future<List<City>> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(key) ?? [];
    List<City> res = [];
    for (String s in list) {
      res.add(City.fromJson(jsonDecode(s)));
    }
    return res;
  }

  Future<void> save(List<City> favs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    for (City c in favs) {
      list.add(jsonEncode(c.toJson()));
    }
    await prefs.setStringList(key, list);
  }
}
