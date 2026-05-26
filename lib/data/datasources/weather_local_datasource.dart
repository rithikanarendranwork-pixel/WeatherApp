import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/weather_model.dart';
/// defining the abstract class for the local data source, which will be implemented by the concrete class below. 
/// this class defines the contract for the local data source, which will be used by the repository to interact with the local storage.
/// the local data source is responsible for caching the weather data, saving and retrieving the list of saved cities, and saving and retrieving the last city that was searched for.
/// the concrete implementation of the local data source uses the shared_preferences package to store the data locally on the device.
abstract interface class WeatherLocalDataSource {
  Future<WeatherModel?> getCachedWeather(String key);
  Future<void>          cacheWeather(String key, WeatherModel w);
  Future<List<String>>  getSavedCities();
  Future<void>          saveCity(String city);
  Future<void>          removeCity(String city);
  Future<String?>       getLastCity();
  Future<void>          setLastCity(String city);
}

final class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  const WeatherLocalDataSourceImpl({required this.prefs});
  final SharedPreferences prefs;
///private variable 
  static String _cacheKey(String k) => 'cache_$k';

  @override
  Future<WeatherModel?> getCachedWeather(String key) async {
    final raw = prefs.getString(_cacheKey(key));
    if (raw == null) return null;

    final data    = jsonDecode(raw) as Map<String, dynamic>;
    final savedAt = data['saved_at'] as int;
    final nowSec  = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (nowSec - savedAt > AppConstants.cacheExpiry.inSeconds) {
      await prefs.remove(_cacheKey(key));
      return null;
    }
    return WeatherModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> cacheWeather(String key, WeatherModel w) async {
    final payload = jsonEncode({
      'saved_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'data': w.toJson(),
    });
    await prefs.setString(_cacheKey(key), payload);
  }

  @override
  Future<List<String>> getSavedCities() async =>
      prefs.getStringList(AppConstants.prefSavedCities) ?? [];

  @override
  Future<void> saveCity(String city) async {
    final cities = await getSavedCities();
    if (!cities.contains(city)) {
      await prefs.setStringList(AppConstants.prefSavedCities, [...cities, city]);
    }
  }

  @override
  Future<void> removeCity(String city) async {
    final cities = await getSavedCities();
    await prefs.setStringList(
      AppConstants.prefSavedCities,
      cities.where((c) => c != city).toList(),
    );
  }

  @override
  Future<String?> getLastCity() => Future.value(prefs.getString(AppConstants.prefLastCity));

  @override
  Future<void> setLastCity(String city) => prefs.setString(AppConstants.prefLastCity, city);
}
