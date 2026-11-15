import 'api_client.dart';
import 'weather.dart';

class WeatherRepository {
  final WeatherApiClient api;
  WeatherRepository(this.api);

  // null если не найден
  Future<City?> findCity(String name) async {
    List list = await api.searchCity(name);
    if (list.isEmpty) return null;
    return City.fromGeo(list[0]);
  }

  Future<Weather> getWeather(City c) async {
    var json = await api.forecast(c.lat, c.lon);
    return Weather.fromJson(c, json);
  }
}
