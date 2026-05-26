import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/weather_model.dart';

abstract interface class WeatherRemoteDataSource {
  Future<WeatherModel>         getCurrentWeatherByCity(String city);
  Future<WeatherModel>         getCurrentWeatherByCoords(double lat, double lon);
  Future<List<ForecastModel>>  getForecastByCity(String city);
  Future<List<ForecastModel>>  getForecastByCoords(double lat, double lon);
}

final class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  const WeatherRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<WeatherModel> getCurrentWeatherByCity(String city) async {
    final json = await apiClient.get(
      AppConstants.currentEp,
      queryParams: {'q': city},
    );
    return WeatherModel.fromJson(json);
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) async {
    final json = await apiClient.get(
      AppConstants.currentEp,
      queryParams: {'lat': '$lat', 'lon': '$lon'},
    );
    return WeatherModel.fromJson(json);
  }

  @override
  Future<List<ForecastModel>> getForecastByCity(String city) async {
    final json = await apiClient.get(
      AppConstants.forecastEp,
      queryParams: {'q': city, 'cnt': '40'},
    );
    return (json['list'] as List)
        .cast<Map<String, dynamic>>()
        .map(ForecastModel.fromJson)
        .toList();
  }

  @override
  Future<List<ForecastModel>> getForecastByCoords(double lat, double lon) async {
    final json = await apiClient.get(
      AppConstants.forecastEp,
      queryParams: {'lat': '$lat', 'lon': '$lon', 'cnt': '40'},
    );
    return (json['list'] as List)
        .cast<Map<String, dynamic>>()
        .map(ForecastModel.fromJson)
        .toList();
  }
}
