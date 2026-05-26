class AppConstants {
  AppConstants._();

  // OpenWeatherMap 
  static const String apiKey = 'use your own api key from openweather.org';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String units = 'metric';
  static const String lang = 'en';

  // Endpoints
  static const String currentEp = '/weather';
  static const String forecastEp = '/forecast';

  // SharedPreferences keys
  static const String prefLastCity = 'last_city';
  static const String prefSavedCities = 'saved_cities';
  static const String prefTempUnit = 'temp_unit';

  // Cache
  static const Duration cacheExpiry = Duration(minutes: 20);
  static const Duration httpTimeout = Duration(seconds: 12);

  // Defaults  // 'imperial' for F
  static const String defaultCity = 'New York';
}
