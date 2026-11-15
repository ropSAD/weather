import 'package:flutter/material.dart';
import 'colors.dart';
import 'weather.dart';
import 'weather_state.dart';

class FavScreen extends StatefulWidget {
  final WeatherState st;
  final ValueChanged<City> onOpen;
  const FavScreen({super.key, required this.st, required this.onOpen});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  WeatherState get st => widget.st;

  @override
  void initState() {
    super.initState();
    st.addListener(update);
  }

  @override
  void dispose() {
    st.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  Widget tile(City c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: btnColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => widget.onOpen(c),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Row(
              children: [
                const Icon(Icons.star, color: orange),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      if (c.region.isNotEmpty)
                        Text(
                          c.region,
                          style: const TextStyle(fontSize: 14, color: gray),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => st.removeFav(c),
                  icon: const Icon(Icons.close, color: gray),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          const Text(
            'Избранное',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (st.favs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Text(
                'Тут пока ничего нет.\nДобавить город можно на экране погоды',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: gray),
              ),
            ),
          for (City c in st.favs) tile(c),
        ],
      ),
    );
  }
}
