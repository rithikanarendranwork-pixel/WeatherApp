import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.lat,
    required super.lon,
    required super.temp,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.humidity,
    required super.windSpeed,
    required super.windDeg,
    required super.pressure,
    required super.visibility,
    required super.clouds,
    required super.condition,
    required super.description,
    required super.iconCode,
    required super.sunrise,
    required super.sunset,
    required super.dt,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> j) {
    final w   = (j['weather'] as List).first as Map<String, dynamic>;
    final m   = j['main']    as Map<String, dynamic>;
    final wnd = j['wind']    as Map<String, dynamic>;
    final sys = j['sys']     as Map<String, dynamic>;
    final cld = j['clouds']  as Map<String, dynamic>;
    final crd = j['coord']   as Map<String, dynamic>;

    return WeatherModel(
      cityName    : j['name'] as String,
      country     : sys['country'] as String,
      lat         : (crd['lat'] as num).toDouble(),
      lon         : (crd['lon'] as num).toDouble(),
      temp        : (m['temp'] as num).toDouble(),
      feelsLike   : (m['feels_like'] as num).toDouble(),
      tempMin     : (m['temp_min'] as num).toDouble(),
      tempMax     : (m['temp_max'] as num).toDouble(),
      humidity    : m['humidity'] as int,
      windSpeed   : (wnd['speed'] as num).toDouble(),
      windDeg     : (wnd['deg'] as num? ?? 0).toInt(),
      pressure    : m['pressure'] as int,
      visibility  : (j['visibility'] as num? ?? 10000).toInt(),
      clouds      : (cld['all'] as num).toInt(),
      condition   : w['main'] as String,
      description : w['description'] as String,
      iconCode    : w['icon'] as String,
      sunrise     : sys['sunrise'] as int,
      sunset      : sys['sunset'] as int,
      dt          : j['dt'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': cityName, 'country': country,
    'lat': lat, 'lon': lon,
    'temp': temp, 'feels_like': feelsLike,
    'temp_min': tempMin, 'temp_max': tempMax,
    'humidity': humidity, 'wind_speed': windSpeed,
    'wind_deg': windDeg, 'pressure': pressure,
    'visibility': visibility, 'clouds': clouds,
    'condition': condition, 'description': description,
    'icon': iconCode, 'sunrise': sunrise,
    'sunset': sunset, 'dt': dt,
  };
}

class ForecastModel extends ForecastSlot {
  const ForecastModel({
    required super.dt,
    required super.temp,
    required super.tempMin,
    required super.tempMax,
    required super.condition,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.pop,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> j) {
    final w = (j['weather'] as List).first as Map<String, dynamic>;
    final m = j['main'] as Map<String, dynamic>;
    final wnd = j['wind'] as Map<String, dynamic>;

    return ForecastModel(
      dt         : j['dt'] as int,
      temp       : (m['temp'] as num).toDouble(),
      tempMin    : (m['temp_min'] as num).toDouble(),
      tempMax    : (m['temp_max'] as num).toDouble(),
      condition  : w['main'] as String,
      description: w['description'] as String,
      iconCode   : w['icon'] as String,
      humidity   : m['humidity'] as int,
      windSpeed  : (wnd['speed'] as num).toDouble(),
      pop        : (j['pop'] as num? ?? 0).toDouble(),
    );
  }
}
