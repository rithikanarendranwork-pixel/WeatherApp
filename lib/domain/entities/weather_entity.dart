/// has every property of weather-- temp/ humidity 
/// has 2 getters - fullLocation and isDay
class WeatherEntity {
  final String cityName;
  final String country;
  final double lat;
  final double lon;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int pressure;
  final int visibility;
  final int clouds;
  final String condition;       // OWM "main" e.g. "Clear"
  final String description;  
  final String iconCode;
  final int sunrise;
  final int sunset;
  final int dt;
/// this as a constructor to initialize all the final variables in the class
  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.clouds,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
    required this.dt,
  });
///getters to access private variables 
  String get fullLocation  => '$cityName, $country';
  bool   get isDay         => DateTime.now().millisecondsSinceEpoch ~/ 1000
                                  >= sunrise &&
                              DateTime.now().millisecondsSinceEpoch ~/ 1000
                                  <= sunset;
}

/// A single 3-hour forecast slot. Used in the 5-day forecast list. 
class ForecastSlot {
  final int dt;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double pop; // probability of precipitation 0–1

  const ForecastSlot({
    required this.dt,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });
}
