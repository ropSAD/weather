import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'colors.dart';
import 'fav_repository.dart';
import 'home_screen.dart';
import 'weather_repository.dart';
import 'weather_state.dart';

void main() {
  // WeatherScreen -> WeatherState -> WeatherRepository -> WeatherApiClient
  WeatherState st = WeatherState(
    WeatherRepository(WeatherApiClient(http.Client())),
    FavRepository(),
  );
  runApp(MyApp(st: st));
  st.start();
}

class MyApp extends StatelessWidget {
  final WeatherState st;
  const MyApp({super.key, required this.st});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Нестабильность',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: orange),
      ),
      home: HomeScreen(st: st),
    );
  }
}
