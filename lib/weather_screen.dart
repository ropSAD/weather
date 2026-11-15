import 'package:flutter/material.dart';
import 'colors.dart';
import 'day_tile.dart';
import 'weather.dart';
import 'weather_icon.dart';
import 'weather_state.dart';

class WeatherScreen extends StatefulWidget {
  final WeatherState st;
  const WeatherScreen({super.key, required this.st});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityCtrl = TextEditingController();

  WeatherState get st => widget.st;

  @override
  void initState() {
    super.initState();
    st.addListener(update);
  }

  @override
  void dispose() {
    st.removeListener(update);
    cityCtrl.dispose();
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  void search() {
    FocusScope.of(context).unfocus();
    st.search(cityCtrl.text);
  }

  Widget searchField() {
    return TextField(
      controller: cityCtrl,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 20, color: Colors.white),
      cursorColor: orange,
      decoration: InputDecoration(
        filled: true,
        fillColor: btnColor,
        hintText: 'Город',
        hintStyle: const TextStyle(color: gray),
        prefixIcon: const Icon(Icons.location_on, color: orange),
        suffixIcon: IconButton(
          onPressed: search,
          icon: const Icon(Icons.search, color: orange),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: (_) => search(),
    );
  }

  // сообщение по центру
  Widget message(IconData icon, String title, String text, {bool retry = false}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 72, color: gray),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: gray),
            ),
            if (retry) const SizedBox(height: 24),
            // кнопка как в калькуляторе
            if (retry)
              SizedBox(
                width: 220,
                height: 56,
                child: Material(
                  color: orange,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: st.retry,
                    child: const Center(
                      child: Text(
                        'Повторить',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget mainCard(Weather w) {
    bool fav = st.isFav(w.city);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 24),
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.city.name,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    if (w.city.region.isNotEmpty)
                      Text(
                        w.city.region,
                        style: const TextStyle(fontSize: 15, color: gray),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => st.toggleFav(w.city),
                icon: Icon(
                  fav ? Icons.star : Icons.star_border,
                  color: orange,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(codeIcon(w.code), size: 72, color: codeColor(w.code)),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        tempStr(w.temp),
                        style: const TextStyle(fontSize: 64, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Text(
                  codeText(w.code),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ощущается как ${tempStr(w.feels)}',
                  style: const TextStyle(fontSize: 16, color: gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // влажность, ветер, давление
  Widget stat(IconData icon, String name, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: orange),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 14, color: gray),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String dayLabel(int i, DayWeather d) {
    if (i == 0) return 'Сегодня';
    if (i == 1) return 'Завтра';
    return d.dateStr();
  }

  Widget weatherList(Weather w) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        mainCard(w),
        const SizedBox(height: 12),
        Row(
          spacing: 12,
          children: [
            stat(Icons.water_drop, 'Влажность', '${w.humidity}%'),
            stat(Icons.air, 'Ветер', '${w.windStr()} м/с'),
            if (w.pressure != null)
              stat(Icons.speed, 'Давление', '${w.pressure!.round()} мм'),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Прогноз на неделю',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < w.days.length; i++)
          DayTile(label: dayLabel(i, w.days[i]), day: w.days[i]),
        const SizedBox(height: 8),
        Text(
          'Прогноз от ${two(w.time.hour)}:${two(w.time.minute)}\n'
          'Данные: met.no, openstreetmap.org',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: gray),
        ),
      ],
    );
  }

  Widget body() {
    if (st.status == Status.loading) {
      return const Center(child: CircularProgressIndicator(color: orange));
    }
    if (st.status == Status.error) {
      return message(
        Icons.cloud_off,
        'Не удалось загрузить погоду',
        st.errMsg,
        retry: true,
      );
    }
    if (st.status == Status.empty) {
      return message(
        Icons.location_off,
        'Город не найден',
        'По запросу "${st.lastQuery}" ничего не найдено',
      );
    }
    if (st.status == Status.success && st.weather != null) {
      return weatherList(st.weather!);
    }
    return message(
      Icons.search,
      'Введите название города',
      'Например: Москва, Казань или Сочи',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: searchField(),
          ),
          Expanded(child: body()),
        ],
      ),
    );
  }
}
