import 'dart:convert';
import 'package:http/http.dart' as http;

// поиск города и погода
const String geoUrl = 'https://nominatim.openstreetmap.org/search';
const String forecastUrl =
    'https://api.met.no/weatherapi/locationforecast/2.0/compact';

// иначе выдаст ошибку
const String userAgent = 'Nestabilnost/1.0 (student lab)';

class ApiError implements Exception {
  final String msg;
  ApiError(this.msg);
}

String errText(Object e) {
  if (e is ApiError) return e.msg;
  return 'Сервер прислал неправильные данные';
}

class WeatherApiClient {
  final http.Client client;
  WeatherApiClient(this.client);

  Future<dynamic> searchCity(String name) {
    String q = Uri.encodeQueryComponent(name);
    return get('$geoUrl?q=$q&format=jsonv2&limit=1&addressdetails=1'
        '&accept-language=ru&featureType=settlement');
  }

  Future<dynamic> forecast(double lat, double lon) {
    return get('$forecastUrl?lat=${lat.toStringAsFixed(4)}'
        '&lon=${lon.toStringAsFixed(4)}');
  }

  Future<dynamic> get(String url) async {
    http.Response resp;
    try {
      resp = await client.get(Uri.parse(url), headers: {
        'User-Agent': userAgent,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw ApiError('Не получилось подключиться к серверу, проверьте интернет соединение');
    }

    if (resp.statusCode == 404) {
      throw ApiError('Данные не найдены (404)');
    }
    if (resp.statusCode >= 500) {
      throw ApiError('Ошибка на сервере (${resp.statusCode}), попробуйте позже');
    }
    // у met.no бывает 203 (не ошибка)
    if (resp.statusCode >= 400) {
      throw ApiError('Ошибка запроса (${resp.statusCode})');
    }
    return jsonDecode(utf8.decode(resp.bodyBytes));
  }
}
