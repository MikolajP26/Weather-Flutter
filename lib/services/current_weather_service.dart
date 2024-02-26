import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/api_weather_service.dart';

class CurrentWeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final LocationService locationService = LocationService();

  Future<String> getApiKey() async {
    String? apiKey = await CurrentApiWeatherService.getApiKey();
    return apiKey ?? '';
  }

  Future<CurrentWeather> getWeather(String cityName) async {
    final apiKey = await getApiKey();

    print('Using API key: $apiKey');

    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401) {
        print('Invalid API key! Using default key.');
        return getWeatherWithDefaultApiKey(cityName);
      } else {
        throw Exception('Failed to load weather data');
      }
    }
  }

  Future<String> getCurrentCity() async {
    return locationService.getCurrentCity();
  }

  Future<void> setApiKey(String apiKey) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=London&appid=$apiKey&units=metric'));

    if (response.statusCode == 401) {
      print('Invalid API key!');
      throw Exception('Invalid API key');
    }

    await CurrentApiWeatherService.setApiKey(apiKey);
  }

  Future<CurrentWeather> getWeatherWithDefaultApiKey(String cityName) async {
    final defaultApiKey = '';

    print('Using default API key: $defaultApiKey');
    final response = await http.get(
        Uri.parse('$BASE_URL?q=$cityName&appid=$defaultApiKey&units=metric'));

    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data with default API key');
    }
  }
}
