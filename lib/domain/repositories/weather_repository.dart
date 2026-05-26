import '../entities/weather_entity.dart';
/// abstract interface from the "interface" key word 
/// fetch weather by city name/ coordinates/ fetching forcasrs and saving cities to local storage
abstract interface class WeatherRepository {
  Future<WeatherEntity>    getCurrentWeather({required String city}); ///city name
  Future<WeatherEntity>    getCurrentWeatherByCoords(double lat, double lon);//coordinates
  Future<List<ForecastSlot>> getForecast({required String city}); ///forecast by city name
  Future<List<ForecastSlot>> getForecastByCoords(double lat, double lon); 
  Future<List<String>>     getSavedCities();
  Future<void>             saveCity(String city);
  Future<void>             removeCity(String city);
  Future<String?>          getLastCity();
}
