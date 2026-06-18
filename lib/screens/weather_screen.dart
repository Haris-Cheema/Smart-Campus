import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/providers/weather_provider.dart';
import 'package:smart_campus/services/weather_service.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weather = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Weather')),
      body: weather.isLoading && weather.weatherData == null
          ? const Center(child: CircularProgressIndicator())
          : weather.error != null && weather.weatherData == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load weather',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(weather.error!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => weather.fetchWeather(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => weather.fetchWeather(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            weather.weatherIcon,
                            style: const TextStyle(fontSize: 72),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${weather.currentTemp.round()}°C',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 52,
                            ),
                          ),
                          Text(
                            weather.weatherDescription,
                            style: theme.textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'NTU Faisalabad',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _WeatherStat(
                                icon: Icons.water_drop,
                                value: '${weather.humidity.round()}%',
                                label: 'Humidity',
                              ),
                              _WeatherStat(
                                icon: Icons.air,
                                value: '${weather.windSpeed.round()} km/h',
                                label: 'Wind',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('5-Day Forecast', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 12),
                  ...weather.forecast.map((day) {
                    final date = DateTime.tryParse(day['date'] ?? '');
                    final dayName = date != null
                        ? DateFormat('EEEE').format(date)
                        : '';
                    final code = (day['weatherCode'] as num?)?.toInt() ?? 0;
                    final maxTemp = (day['maxTemp'] as num?)?.round() ?? 0;
                    final minTemp = (day['minTemp'] as num?)?.round() ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(
                          WeatherService.weatherIcon(code),
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          dayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(WeatherService.weatherDescription(code)),
                        trailing: Text(
                          '$maxTemp° / $minTemp°',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _WeatherStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
