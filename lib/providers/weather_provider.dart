import 'package:flutter/foundation.dart';
import 'package:smart_campus/services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get currentTemp {
    return (_weatherData?['current']?['temperature_2m'] as num?)?.toDouble() ??
        0;
  }

  int get currentWeatherCode {
    return (_weatherData?['current']?['weather_code'] as num?)?.toInt() ?? 0;
  }

  double get humidity {
    return (_weatherData?['current']?['relative_humidity_2m'] as num?)
            ?.toDouble() ??
        0;
  }

  double get windSpeed {
    return (_weatherData?['current']?['wind_speed_10m'] as num?)?.toDouble() ??
        0;
  }

  String get weatherDescription =>
      WeatherService.weatherDescription(currentWeatherCode);
  String get weatherIcon => WeatherService.weatherIcon(currentWeatherCode);

  List<Map<String, dynamic>> get forecast {
    final daily = _weatherData?['daily'];
    if (daily == null) return [];

    final List<String> dates = List<String>.from(daily['time'] ?? []);
    final List maxTemps = daily['temperature_2m_max'] ?? [];
    final List minTemps = daily['temperature_2m_min'] ?? [];
    final List codes = daily['weather_code'] ?? [];

    return List.generate(
      dates.length,
      (i) => {
        'date': dates[i],
        'maxTemp': maxTemps[i],
        'minTemp': minTemps[i],
        'weatherCode': codes[i],
      },
    );
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _service.fetchWeather();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
