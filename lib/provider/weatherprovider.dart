import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_weather_app/models/geocode.dart';
import 'package:flutter_news_weather_app/models/newsmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/additionalweatherdata.dart';
import '../models/dailyweather.dart';
import '../models/hourlyWeather.dart';
import '../models/weather.dart';

class WeatherProvider with ChangeNotifier {
  String apiKey = "0e913a39fc67a26ca10df2b0070e9ccb";
  Weather? weather;
  AdditionalWeatherData? additionalWeatherData;
  LatLng? currentLocation;
  List<HourlyWeather> hourlyWeather = [];
  List<DailyWeather> dailyWeather = [];
  bool isLoading = false;
  bool isRequestError = false;
  bool isSearchError = false;
  bool isLocationServiceEnabled = false;
  LocationPermission? locationPermission;
  List<Article> articleList = [];
  bool isCelsius = true;
  Dio dio = Dio();

  String get measurementUnit => isCelsius ? '°C' : '°F';

  // 1. Location Permission Handling
  Future<Position?> requestLocation(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location service is disabled. Please enable it.')),
        );
        return Future.error('Location services are disabled.');
      }

      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is denied.')),
          );
          return Future.error('Location permissions are denied');
        }
      }

      if (locationPermission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied.')),
        );
        return Future.error('Location permissions are permanently denied');
      }

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      return await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $error')),
      );
      return Future.error('Error occurred while fetching location: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch Weather Data
  Future<void> getWeatherData(BuildContext context,
      {bool notify = false}) async {
    isLoading = true;
    isRequestError = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context);

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      await getDailyWeather(currentLocation!);
    } catch (e) {
      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 3. Fetch Current Weather
  Future<void> getCurrentWeather(LatLng location) async {
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey';
    try {
      final response = await dio.get(url);

      Map<String, dynamic> extractedData;
      if (response.data is String) {
        extractedData = jsonDecode(response.data);
      } else {
        extractedData = response.data as Map<String, dynamic>;
      }

      weather = Weather.fromJson(extractedData);
    } catch (error) {
      isLoading = false;
      isRequestError = true;
    }
  }

  // 4. Fetch 5-day Weather Forecast
  Future<void> getDailyWeather(LatLng location) async {
    isLoading = true;
    notifyListeners();

    String dailyUrl =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey";

    try {
      final response = await dio.get(dailyUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['list'] != null) {
          final List<dynamic> forecastList = data['list'];

          dailyWeather = forecastList
              .map((dailyJson) => DailyWeather.fromDailyJson(dailyJson))
              .toList();
        }
      } else {
        isRequestError = true;
      }
    } catch (error) {
      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 5. Search weather by location name
  Future<void> searchWeather(String location) async {
    isLoading = true;
    notifyListeners();
    isRequestError = false;

    try {
      GeoCodeData? geoCodeData = await locationToLatLng(location);

      if (geoCodeData != null) {
        await getCurrentWeather(geoCodeData.latLng);
        await getDailyWeather(geoCodeData.latLng);

        weather!.city = geoCodeData.name;
      } else {
        isSearchError = true;
      }
    } catch (e) {
      isSearchError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 6. Toggle between Celsius and Fahrenheit
  void switchTempUnit() {
    isCelsius = !isCelsius;
    notifyListeners();
  }

  // 7. Fetch News Based on Current Location and Weather Condition
  Future<void> fetchNewsBasedOnWeather(
    String selectedLanguages,
    List<String> selectedCategories,
  ) async {
    isLoading = true;
    isRequestError = false;
    notifyListeners();
    try {
      String mood;
      String newsKey = "pub_56344e280290d6efcba20263847c87369f27d";
      String categoryQuery = selectedCategories.isNotEmpty
          ? selectedCategories.join(',').toLowerCase()
          : '';

      if (weather != null) {
        if (weather!.temp < 15) {
          mood = "Depression"; // Cold weather
        } else if (weather!.temp >= 15 && weather!.temp < 25) {
          mood = "Happy"; // Cool weather
        } else {
          mood = "Fear"; // Hot weather
        }
      } else {
        mood = "Normal"; // Default mood
      }

      String newsUrl =
          "https://newsdata.io/api/1/news?apikey=$newsKey&q=$mood&country=in&language=$selectedLanguages&category=$categoryQuery";

      final response = await dio.get(newsUrl,
          options: Options(headers: {
            "apikey": newsKey,
          }));

      if (response.statusCode == 200) {
        final newsData = response.data;

        if (newsData['status'] == 'success' && newsData['results'] != null) {
          final List<dynamic> articles = newsData['results'];
          articleList =
              articles.map((article) => Article.fromJson(article)).toList();
        } else {
          isRequestError = true;
        }
      } else {
        isRequestError = true;
      }
    } on DioException {
      isRequestError = true;
    } catch (error) {
      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

//8 Fetch Lat long
  Future<GeoCodeData?> locationToLatLng(String location) async {
    try {
      String url =
          'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey';

      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> jsonList = response.data;

        if (jsonList.isNotEmpty) {
          return GeoCodeData.fromJson(jsonList.first);
        }
      }
    } catch (error) {
      isRequestError = true;
    }
    return null;
  }
}
