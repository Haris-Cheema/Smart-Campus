import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const double _campusLat = 31.4621;
  static const double _campusLon = 73.1485;

  Future<Map<String, dynamic>> fetchWeather() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?latitude=$_campusLat&longitude=$_campusLon'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code'
        '&timezone=Asia%2FKarachi&forecast_days=5',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw HttpException('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

  static String weatherDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String weatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 57) return '🌦️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌧️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
