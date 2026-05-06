import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Weather'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.orange, size: 80),
                    const SizedBox(height: 16),
                    Text('28°C', style: theme.textTheme.displayLarge?.copyWith(fontSize: 48)),
                    Text('Sunny', style: theme.textTheme.displayMedium),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WeatherDetail(icon: Icons.water_drop, label: 'Humidity', value: '45%'),
                        _WeatherDetail(icon: Icons.air, label: 'Wind', value: '12 km/h'),
                        _WeatherDetail(icon: Icons.compress, label: 'Pressure', value: '1012 hPa'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Forecast', style: theme.textTheme.displaySmall),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  _ForecastRow(day: 'Monday', temp: '29°C', icon: Icons.wb_sunny, color: Colors.orange),
                  _ForecastRow(day: 'Tuesday', temp: '27°C', icon: Icons.cloud, color: Colors.grey),
                  _ForecastRow(day: 'Wednesday', temp: '25°C', icon: Icons.water_drop, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetail({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final String day;
  final String temp;
  final IconData icon;
  final Color color;

  const _ForecastRow({required this.day, required this.temp, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
