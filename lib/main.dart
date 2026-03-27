import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umuhinzi_plus/features/home/data/services/weather_service.dart';
import 'package:umuhinzi_plus/features/home/data/repositories/weather_repository.dart';
import 'package:umuhinzi_plus/features/home/presentation/bloc/weather/weather_bloc.dart';
import 'features/weather/weather_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // We wrap the home page with the BlocProvider here
      home: BlocProvider(
        create: (context) => WeatherBloc(
          weatherRepository: WeatherRepository(
            weatherService: WeatherService(),
          ),
        ),
        child: const WeatherPage(),
      ),
    );
  }
}