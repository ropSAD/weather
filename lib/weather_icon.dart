import 'package:flutter/material.dart';
import 'colors.dart';

// значок по коду погоды
IconData codeIcon(String s) {
  if (s == 'clearsky_night' || s == 'fair_night') return Icons.nights_stay;
  String b = s.split('_')[0];
  if (b == 'clearsky' || b == 'fair') return Icons.wb_sunny;
  if (b == 'partlycloudy') return Icons.cloud_queue;
  if (b == 'cloudy') return Icons.cloud;
  if (b == 'fog') return Icons.foggy;
  if (b.contains('thunder')) return Icons.thunderstorm;
  if (b.contains('snow') || b.contains('sleet')) return Icons.ac_unit;
  if (b.contains('rain')) return Icons.umbrella;
  return Icons.help_outline;
}

Color codeColor(String s) {
  if (s == 'clearsky_night' || s == 'fair_night') return Colors.white;
  String b = s.split('_')[0];
  if (b == 'clearsky' || b == 'fair') return orange;
  if (b.contains('thunder')) return Colors.amberAccent;
  if (b.contains('snow') || b.contains('sleet')) return Colors.white;
  if (b.contains('rain')) return Colors.lightBlueAccent;
  return gray; // облака и туман
}
