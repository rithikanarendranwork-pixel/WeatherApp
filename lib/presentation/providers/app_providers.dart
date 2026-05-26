import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
/// wriring diagram for app. 
/// has provider (DB)s for infrastructure (http client, shared prefs), data sources (remote and local), repository, use cases, and app state (active city, current weather, forecast, saved cities)
import '../../core/network/api_client.dart';
import '../../data/datasources/weather_local_datasource.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/weather_usecases.dart';

// Infrastructure
// DB to keep cached weather
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

// HTTP client for API calls (cleans up)
final httpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});
///convert api client to provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final c = ApiClient(client: ref.watch(httpClientProvider));
  ref.onDispose(c.dispose);
  return c;
});

// Data sources 
// fetch from internet
final remoteDataSourceProvider = Provider<WeatherRemoteDataSource>(
  (ref) => WeatherRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider)),
);
// fetch from local storage  this is from data files
final localDataSourceProvider = Provider<WeatherLocalDataSource>(
  (ref) => WeatherLocalDataSourceImpl(prefs: ref.watch(sharedPreferencesProvider)),
);

// Repository merge from both data sources and provide repository to use cases
final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(
    remote: ref.watch(remoteDataSourceProvider),
    local:  ref.watch(localDataSourceProvider),
  ),
);

// Use Cases
//gets weather for a city
// gets 5-day forecast for a city
// gets list of saved cities
// saves a city to favorites
// removes a city from favorites
final getCurrentWeatherProvider  = Provider((ref) => GetCurrentWeather(ref.watch(weatherRepositoryProvider)));
final getForecastProvider        = Provider((ref) => GetForecast(ref.watch(weatherRepositoryProvider)));
final getSavedCitiesProvider     = Provider((ref) => GetSavedCities(ref.watch(weatherRepositoryProvider)));
final saveCityProvider           = Provider((ref) => SaveCity(ref.watch(weatherRepositoryProvider)));
final removeCityProvider         = Provider((ref) => RemoveCity(ref.watch(weatherRepositoryProvider)));

// App State 

/// The city currently displayed
final activeCityProvider = StateProvider<String>(
  (ref) => 'New York',
);

/// Current weather (auto-refreshes when activeCityProvider changes)
final currentWeatherProvider = FutureProvider.autoDispose<WeatherEntity>((ref) {
  final city    = ref.watch(activeCityProvider);
  final useCase = ref.watch(getCurrentWeatherProvider);
  return useCase(city);
});

/// 5-day forecast (auto-refreshes when activeCityProvider changes)
final forecastProvider = FutureProvider.autoDispose<List<ForecastSlot>>((ref) {
  final city    = ref.watch(activeCityProvider);
  final useCase = ref.watch(getForecastProvider);
  return useCase(city);
});

/// Saved cities list
final savedCitiesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(getSavedCitiesProvider)();
});
