import 'package:flutter/cupertino.dart';

class DailyWeather with ChangeNotifier {
  final double temp;
  final double tempMin;
  final double tempMax;
  final double tempMorning;
  final double tempDay;
  final double tempEvening;
  final double tempNight;
  final String weatherCategory;
  final String condition;
  final DateTime date;
  final String precipitation;
  final double uvi;
  final Map<String,dynamic> clouds;
  final int humidity;

  DailyWeather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.tempMorning,
    required this.tempDay,
    required this.tempEvening,
    required this.tempNight,
    required this.weatherCategory,
    required this.condition,
    required this.date,
    required this.precipitation,
    required this.uvi,
    required this.clouds,
    required this.humidity,
  });

  static DailyWeather fromDailyJson(dynamic json) {
    return DailyWeather(
      temp: (json['temp']?['day'] ?? 0.0).toDouble(),
      tempMin: (json['temp']?['min'] ?? 0.0).toDouble(),
      tempMax: (json['temp']?['max'] ?? 0.0).toDouble(),
      tempMorning: (json['feels_like']?['morn'] ?? 0.0).toDouble(),
      tempDay: (json['feels_like']?['day'] ?? 0.0).toDouble(),
      tempEvening: (json['feels_like']?['eve'] ?? 0.0).toDouble(),
      tempNight: (json['feels_like']?['night'] ?? 0.0).toDouble(),
      weatherCategory: json['weather']?[0]?['main'] ?? 'Unknown',
      condition: json['weather']?[0]?['description'] ?? 'Unknown',
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
      precipitation: ((json['pop'] ?? 0.0) * 100).toStringAsFixed(0),
      clouds: json['clouds'] ?? 0,
      humidity: json['humidity'] ?? 0,
      uvi: (json['uvi'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'DailyWeather(temp: $temp, condition: $condition, date: $date)';
  }
}
