import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=47b9fc8b1386e7d8c4874751a597ab6e',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'].toString() != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weatherFuture = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data as Map<String, dynamic>;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'] - 273.15;
          final currentsky = currentWeatherData['weather'][0]['main'];
          final humidity = currentWeatherData['main']['humidity'].toString();
          final windSpeed = currentWeatherData['wind']['speed'].toString();
          final pressure = currentWeatherData['main']['pressure'].toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          TimeOfDay.now().format(context),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${currentTemp.toStringAsFixed(2)} °C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          (currentsky == 'Clouds' || currentsky == 'Rain')
                              ? Icons.cloud
                              : Icons.sunny,
                          size: 70,
                        ),
                        Text(currentsky, style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Hourlyforecast(
                          time:
                              DateTime.parse(
                                data['list'][i + 1]['dt_txt'],
                              ).hour.toString().padLeft(2, '0') +
                              ':00',
                          icon:
                              (data['list'][i + 1]['weather'][0]['main'] ==
                                          'Clouds' ||
                                      data['list'][i +
                                              1]['weather'][0]['main'] ==
                                          'Rain')
                                  ? Icons.cloud
                                  : Icons.sunny,
                          temp:
                              (data['list'][i + 1]['main']['temp'] - 273.15)
                                  .toStringAsFixed(1) +
                              '°C',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Additional Information',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalWidget(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: humidity,
                    ),
                    AdditionalWidget(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: windSpeed,
                    ),
                    AdditionalWidget(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: pressure,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdditionalWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class Hourlyforecast extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;

  const Hourlyforecast({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Icon(icon, size: 32),
            Text(temp),
          ],
        ),
      ),
    );
  }
}
