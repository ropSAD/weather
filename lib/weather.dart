import 'dart:math';

const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

const List<String> months = [
  'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
  'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
];

double toD(dynamic v) {
  return (v as num).toDouble();
}

String two(int n) {
  return n.toString().padLeft(2, '0');
}

// 17.6 -> +18°
String tempStr(double t) {
  int r = t.round();
  if (r > 0) {
    return '+$r°';
  }
  return '$r°';
}

// текст по коду погоды
String codeText(String code) {
  String b = code.split('_')[0];
  switch (b) {
    case 'clearsky':
      return 'Ясно';
    case 'fair':
      return 'Малооблачно';
    case 'partlycloudy':
      return 'Переменная облачность';
    case 'cloudy':
      return 'Пасмурно';
    case 'fog':
      return 'Туман';
  }
  if (b.contains('thunder')) return 'Гроза';
  if (b.contains('sleet')) return 'Мокрый снег';
  if (b.contains('snow')) {
    if (b.startsWith('light')) return 'Небольшой снег';
    if (b.startsWith('heavy')) return 'Сильный снег';
    return 'Снег';
  }
  if (b.contains('rainshowers')) return 'Ливень';
  if (b.startsWith('lightrain')) return 'Небольшой дождь';
  if (b.startsWith('heavyrain')) return 'Сильный дождь';
  if (b.contains('rain')) return 'Дождь';
  return 'Нет данных';
}

String? symbol(Map<String, dynamic> data, String key) {
  if (data[key] == null) {
    return null;
  }
  return data[key]['summary']['symbol_code'];
}

class City {
  final int id;
  final String name;
  final String region; // область и страна
  final double lat;
  final double lon;

  City(this.id, this.name, this.region, this.lat, this.lon);

  // из ответа openstreetmap
  factory City.fromGeo(Map<String, dynamic> json) {
    Map<String, dynamic> a = json['address'] ?? {};
    String name = json['name'];
    List<String> parts = [];
    // чтобы не было "Москва, Москва, Россия"
    if (a['state'] != null && a['state'] != name) {
      parts.add(a['state']);
    }
    if (a['country'] != null) {
      parts.add(a['country']);
    }
    return City(
      json['osm_id'],
      name,
      parts.join(', '),
      double.parse(json['lat']),
      double.parse(json['lon']),
    );
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      json['id'],
      json['name'],
      json['region'],
      toD(json['lat']),
      toD(json['lon']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'region': region, 'lat': lat, 'lon': lon};
  }
}

class DayWeather {
  final DateTime date;
  String code = '';
  double max;
  double min;

  DayWeather(this.date, this.max, this.min);

  // показ даты и дня недели (Чт, 16 окт)
  String dateStr() {
    return '${weekDays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class Weather {
  final City city;
  final double temp;
  final double feels;
  final String code;
  final int humidity;
  final double wind;
  final double? pressure; // мм рт. ст.
  final DateTime time; // время прогноза
  final List<DayWeather> days;

  Weather({
    required this.city,
    required this.temp,
    required this.feels,
    required this.code,
    required this.humidity,
    required this.wind,
    this.pressure,
    required this.time,
    required this.days,
  });

  // сборка дневных прогнозов (от api приходит по часам)
  factory Weather.fromJson(City city, Map<String, dynamic> json) {
    List ts = json['properties']['timeseries'];
    Map<String, dynamic> now = ts[0]['data'];
    Map<String, dynamic> cur = now['instant']['details'];

    List<DayWeather> days = [];
    for (Map<String, dynamic> t in ts) {
      DateTime local = DateTime.parse(t['time']).toLocal();
      DateTime date = DateTime(local.year, local.month, local.day);
      double temp = toD(t['data']['instant']['details']['air_temperature']);

      if (days.isEmpty || days.last.date != date) {
        if (days.length == 7) {
          break;
        }
        days.add(DayWeather(date, temp, temp));
      }
      DayWeather d = days.last;
      if (temp > d.max) d.max = temp;
      if (temp < d.min) d.min = temp;

      // значок дня
      String? s = symbol(t['data'], 'next_6_hours') ??
          symbol(t['data'], 'next_1_hours');
      if (s != null && (d.code.isEmpty || local.hour <= 12)) {
        d.code = s;
      }
    }

    double temp = toD(cur['air_temperature']);
    double hum = toD(cur['relative_humidity']);
    double wind = toD(cur['wind_speed']);

    double? p;
    if (cur['air_pressure_at_sea_level'] != null) {
      p = toD(cur['air_pressure_at_sea_level']) * 0.750062; // гПа в мм рт. ст.
    }

    return Weather(
      city: city,
      temp: temp,
      feels: feelsLike(temp, hum, wind),
      code: symbol(now, 'next_1_hours') ?? symbol(now, 'next_6_hours') ?? '',
      humidity: hum.round(),
      wind: wind,
      pressure: p,
      time: DateTime.parse(json['properties']['meta']['updated_at']).toLocal(),
      days: days,
    );
  }

  // ощущается как (формула с википедии)
  static double feelsLike(double t, double hum, double wind) {
    double e = hum / 100 * 6.105 * exp(17.27 * t / (237.7 + t));
    return t + 0.33 * e - 0.70 * wind - 4.00;
  }

  String windStr() {
    return wind.toStringAsFixed(1).replaceAll('.', ',');
  }
}
