import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

/// Each use case encapsulates one business action.
/// seperate logic for business testing and UI testing.
/// 
/// extended from the repo
final class GetCurrentWeather {
  const GetCurrentWeather(this._repo);
  final WeatherRepository _repo;
  Future<WeatherEntity> call(String city) => _repo.getCurrentWeather(city: city);
}

final class GetCurrentWeatherByCoords {
  const GetCurrentWeatherByCoords(this._repo);
  final WeatherRepository _repo;
  Future<WeatherEntity> call(double lat, double lon) =>
      _repo.getCurrentWeatherByCoords(lat, lon);
}

final class GetForecast {
  const GetForecast(this._repo);
  final WeatherRepository _repo;
  Future<List<ForecastSlot>> call(String city) => _repo.getForecast(city: city);
}

final class GetForecastByCoords {
  const GetForecastByCoords(this._repo);
  final WeatherRepository _repo;
  Future<List<ForecastSlot>> call(double lat, double lon) =>
      _repo.getForecastByCoords(lat, lon);
}

final class GetSavedCities {
  const GetSavedCities(this._repo);
  final WeatherRepository _repo;
  Future<List<String>> call() => _repo.getSavedCities();
}

final class SaveCity {
  const SaveCity(this._repo);
  final WeatherRepository _repo;
  Future<void> call(String city) => _repo.saveCity(city);
}

final class RemoveCity {
  const RemoveCity(this._repo);
  final WeatherRepository _repo;
  Future<void> call(String city) => _repo.removeCity(city);
}
