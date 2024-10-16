import 'package:equatable/equatable.dart';

class HourlyWeather extends Equatable {
  final double temp;
  final String weatherCategory;
  final String? condition;
  final DateTime date;

  const HourlyWeather({
    required this.temp,
    required this.weatherCategory,
    this.condition,
    required this.date,
  });

  static HourlyWeather fromJson(dynamic json) {
    return HourlyWeather(
      temp: (json['temp']).toDouble(),
      weatherCategory: json['weather'][0]['main'],
      condition: json['weather'][0]['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

  @override
  List<Object?> get props => [
        temp,
        weatherCategory,
        condition,
        date,
      ];
}
