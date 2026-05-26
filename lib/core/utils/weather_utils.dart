import 'package:intl/intl.dart';

class WeatherUtils {
  WeatherUtils._();

  static String iconUrl(String code) =>
      'https://openweathermap.org/img/wn/$code@2x.png';

  static String formatTemp(double t) => '${t.round()}°';

  static String formatDate(int ts) =>
      DateFormat('EEE, MMM d').format(_dt(ts));

  static String formatDay(int ts) {
    final d = _dt(ts);
    final today = DateTime.now();
    if (d.day == today.day && d.month == today.month) return 'Today';
    return DateFormat('EEE').format(d);
  }

  static String formatTime(int ts) =>
      DateFormat('h:mm a').format(_dt(ts));

  static String formatHour(int ts) =>
      DateFormat('ha').format(_dt(ts));

  static bool isDaytime(int sunrise, int sunset) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= sunrise && now <= sunset;
  }

  static String windDir(int deg) {
    const dirs = ['N','NE','E','SE','S','SW','W','NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }

  static String formatVisibility(int meters) =>
      meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} km' : '${meters}m';

  static String uvLabel(double uvi) => switch (uvi) {
    < 3  => 'Low',
    < 6  => 'Moderate',
    < 8  => 'High',
    < 11 => 'Very High',
    _    => 'Extreme',
  };

  // Emoji per OWM main condition
  static String conditionEmoji(String condition) => switch (condition) {
    'Clear'        => '☀️',
    'Clouds'       => '☁️',
    'Rain'         => '🌧️',
    'Drizzle'      => '🌦️',
    'Thunderstorm' => '⛈️',
    'Snow'         => '❄️',
    'Mist' || 'Fog' || 'Haze' => '🌫️',
    'Smoke' || 'Ash'  => '💨',
    'Dust'  || 'Sand' => '🌪️',
    'Squall'       => '🌬️',
    'Tornado'      => '🌪️',
    _              => '🌤️',
  };

  static DateTime _dt(int ts) =>
      DateTime.fromMillisecondsSinceEpoch(ts * 1000);
}
