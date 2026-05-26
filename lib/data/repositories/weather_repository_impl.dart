import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';

final class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final WeatherRemoteDataSource remote;
  final WeatherLocalDataSource  local;

  @override
  Future<WeatherEntity> getCurrentWeather({required String city}) async {
    // Cache-first strategy
    final cached = await local.getCachedWeather(city.toLowerCase());
    if (cached != null) return cached;

    final fresh = await remote.getCurrentWeatherByCity(city);
    await local.cacheWeather(city.toLowerCase(), fresh);
    await local.setLastCity(city);
    return fresh;
  }

  @override
  Future<WeatherEntity> getCurrentWeatherByCoords(double lat, double lon) async {
    final fresh = await remote.getCurrentWeatherByCoords(lat, lon);
    await local.cacheWeather(fresh.cityName.toLowerCase(), fresh);
    await local.setLastCity(fresh.cityName);
    return fresh;
  }

  @override
  Future<List<ForecastSlot>> getForecast({required String city}) =>
      remote.getForecastByCity(city);

  @override
  Future<List<ForecastSlot>> getForecastByCoords(double lat, double lon) =>
      remote.getForecastByCoords(lat, lon);

  @override
  Future<List<String>> getSavedCities() => local.getSavedCities();

  @override
  Future<void> saveCity(String city) => local.saveCity(city);

  @override
  Future<void> removeCity(String city) => local.removeCity(city);

  @override
  Future<String?> getLastCity() => local.getLastCity();
}
