import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'fav_repository.dart';
import 'weather.dart';
import 'weather_repository.dart';

// none - ничего не искали
enum Status { none, loading, success, empty, error }

class WeatherState extends ChangeNotifier {
  final WeatherRepository repo;
  final FavRepository favRepo;
  WeatherState(this.repo, this.favRepo);

  Status status = Status.none;
  String errMsg = '';
  Weather? weather;
  List<City> favs = [];

  // для кнопки повторить
  String lastQuery = '';
  City? lastCity;

  // при запуске первый город из избранного или Москва
  Future<void> start() async {
    favs = await favRepo.load();
    if (favs.isNotEmpty) {
      loadCity(favs[0]);
    } else {
      search('Москва');
    }
  }

  Future<void> search(String text) async {
    if (status == Status.loading) return;
    text = text.trim();
    if (text.isEmpty) {
      lastQuery = '';
      lastCity = null;
      status = Status.none;
      notifyListeners();
      return;
    }

    lastQuery = text;
    lastCity = null;
    status = Status.loading;
    notifyListeners();

    try {
      City? c = await repo.findCity(text);
      if (c == null) {
        status = Status.empty;
        notifyListeners();
        return;
      }
      weather = await repo.getWeather(c);
      status = Status.success;
      notifyListeners();
    } catch (e) {
      showErr(errText(e));
    }
  }

  // для избранного, без поиска
  Future<void> loadCity(City c) async {
    if (status == Status.loading) return;
    lastQuery = '';
    lastCity = c;
    status = Status.loading;
    notifyListeners();

    try {
      weather = await repo.getWeather(c);
      status = Status.success;
      notifyListeners();
    } catch (e) {
      showErr(errText(e));
    }
  }

  void retry() {
    if (lastCity != null) {
      loadCity(lastCity!);
    } else {
      search(lastQuery);
    }
  }

  void showErr(String msg) {
    errMsg = msg;
    status = Status.error;
    notifyListeners();
  }

  bool isFav(City c) {
    return favs.any((f) => f.id == c.id);
  }

  void toggleFav(City c) {
    if (isFav(c)) {
      favs.removeWhere((f) => f.id == c.id);
    } else {
      favs.add(c);
    }
    favRepo.save(favs);
    notifyListeners();
  }

  void removeFav(City c) {
    favs.removeWhere((f) => f.id == c.id);
    favRepo.save(favs);
    notifyListeners();
  }
}
