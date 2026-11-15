import 'package:flutter/material.dart';
import 'colors.dart';
import 'fav_screen.dart';
import 'weather.dart';
import 'weather_screen.dart';
import 'weather_state.dart';

// две вкладки снизу - погода и избранное
class HomeScreen extends StatefulWidget {
  final WeatherState st;
  const HomeScreen({super.key, required this.st});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;

  void openCity(City c) {
    widget.st.loadCity(c);
    setState(() {
      tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      // чтобы текст в поиске не пропадал
      body: IndexedStack(
        index: tab,
        children: [
          WeatherScreen(st: widget.st),
          FavScreen(st: widget.st, onOpen: openCity),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        backgroundColor: bg,
        selectedItemColor: orange,
        unselectedItemColor: gray,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Погода'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Избранное'),
        ],
      ),
    );
  }
}
