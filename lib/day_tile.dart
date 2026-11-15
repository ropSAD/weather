import 'package:flutter/material.dart';
import 'colors.dart';
import 'weather.dart';
import 'weather_icon.dart';

// один день в прогнозе
class DayTile extends StatelessWidget {
  final String label;
  final DayWeather day;
  const DayTile({super.key, required this.label, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  codeText(day.code),
                  style: const TextStyle(fontSize: 14, color: gray),
                ),
              ],
            ),
          ),
          Icon(codeIcon(day.code), color: codeColor(day.code), size: 30),
          const SizedBox(width: 16),
          SizedBox(
            width: 84,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Text(
                    tempStr(day.max),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tempStr(day.min),
                    style: const TextStyle(fontSize: 18, color: gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
