import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';
import '../../core/utils/weather_utils.dart';
import '../../domain/entities/weather_entity.dart';
//extends stateless widget-- UI never changes 
//takes data in 
class GlassCard extends StatelessWidget {
  //const-- flutter can cache and resuse this object
  const GlassCard({ //const-- complie time constant. 
    super.key,
    //only required child, rest have default values
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius  = 20.0,
    this.color   = AppColors.glass,
  });
  
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color  color;

  @override
  //build method returns a container with padding, background color, border radius and border, and the child widget inside it
  Widget build(BuildContext context) => Container(
        padding   : padding,
        decoration: BoxDecoration(
          color       : color,
          borderRadius: BorderRadius.circular(radius),
          border      : Border.all(color: AppColors.glassBorder),
        ),
        child: child,
      );
}
//stateful widget--  and _wether gradient background-- changes based on weather condition, animates between old and new gradients when condition changes

class WeatherGradientBackground extends StatefulWidget {
  const WeatherGradientBackground({
    super.key,
    required this.condition,
    required this.child,
  });

  final String condition;
  final Widget child;

  @override
  State<WeatherGradientBackground> createState() =>
      _WeatherGradientBackgroundState();
}

class _WeatherGradientBackgroundState
    extends State<WeatherGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;
  List<Color>? _oldColors;

  @override
  void initState() {
    super.initState();
    //private variables for animation controller and animation, initialized in initState
    
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward(from: 1.0);
  }

  @override
  void didUpdateWidget(covariant WeatherGradientBackground old) {
    super.didUpdateWidget(old);
    if (old.condition != widget.condition) {
      _oldColors = AppColors.gradientForCondition(old.condition);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newColors = AppColors.gradientForCondition(widget.condition);

    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, child) {
        final colors = _oldColors == null
            ? newColors
            : List.generate(
                newColors.length,
                (i) => Color.lerp(
                  _oldColors![i.clamp(0, _oldColors!.length - 1)],
                  newColors[i],
                  _anim.value,
                )!,
              );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin   : Alignment.topCenter,
              end     : Alignment.bottomCenter,
              colors  : colors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

//Temperature Hero

class TemperatureHero extends StatelessWidget {
  const TemperatureHero({super.key, required this.weather});
  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(weather.cityName, style: AppTextStyles.cityName),
          const SizedBox(height: 2),
          Text(weather.country, style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text(
            WeatherUtils.conditionEmoji(weather.condition),
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 4),
          Text(
            WeatherUtils.formatTemp(weather.temp),
            style: AppTextStyles.tempHero(96),
          ),
          Text(
            weather.description.toUpperCase(),
            style: AppTextStyles.condition,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('H: ${WeatherUtils.formatTemp(weather.tempMax)}',
                  style: AppTextStyles.bodyBold),
              const SizedBox(width: 20),
              Text('L: ${WeatherUtils.formatTemp(weather.tempMin)}',
                  style: AppTextStyles.body),
            ],
          ),
        ],
      );
}

// Stats Row (feels-like / humidity / wind / pressure)

class WeatherStatsGrid extends StatelessWidget {
  const WeatherStatsGrid({super.key, required this.weather});
  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat(Icons.thermostat_outlined,       'FEELS LIKE',
          WeatherUtils.formatTemp(weather.feelsLike)),
      _Stat(Icons.water_drop_outlined,       'HUMIDITY',
          '${weather.humidity}%'),
      _Stat(Icons.air,                       'WIND',
          '${weather.windSpeed.round()} m/s '
          '${WeatherUtils.windDir(weather.windDeg)}'),
      _Stat(Icons.compress,                  'PRESSURE',
          '${weather.pressure} hPa'),
      _Stat(Icons.visibility_outlined,       'VISIBILITY',
          WeatherUtils.formatVisibility(weather.visibility)),
      _Stat(Icons.cloud_outlined,            'CLOUD COVER',
          '${weather.clouds}%'),
    ];

    return GridView.count(
      crossAxisCount  : 2,
      shrinkWrap      : true,
      physics         : const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing : 10,
      childAspectRatio: 1.55,
      children        : stats.map(_buildTile).toList(),
    );
  }

  Widget _buildTile(_Stat s) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment : MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(s.icon, color: AppColors.white40, size: 13),
              const SizedBox(width: 5),
              Text(s.label, style: AppTextStyles.sectionLabel),
            ]),
            Text(s.value, style: AppTextStyles.cardValue),
          ],
        ),
      );
}

class _Stat {
  const _Stat(this.icon, this.label, this.value);
  final IconData icon;
  final String   label;
  final String   value;
}

// Sunrise / Sunset Card 

class SunriseSunsetCard extends StatelessWidget {
  const SunriseSunsetCard({super.key, required this.weather});
  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    final nowSec   = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final total    = (weather.sunset - weather.sunrise).toDouble();
    final elapsed  = (nowSec - weather.sunrise).clamp(0, total.toInt()).toDouble();
    final progress = (total > 0) ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(Icons.wb_twilight, 'SUNRISE / SUNSET'),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value          : progress,
                  backgroundColor: AppColors.white20,
                  valueColor     : const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
                  minHeight      : 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeCol('🌅', 'Sunrise', WeatherUtils.formatTime(weather.sunrise)),
              _timeCol('🌇', 'Sunset',  WeatherUtils.formatTime(weather.sunset),
                  align: CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }

  Column _timeCol(String emoji, String label, String time,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) =>
      Column(
        crossAxisAlignment: align,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Text(time,  style: AppTextStyles.cardValue.copyWith(fontSize: 16)),
          Text(label, style: AppTextStyles.cardLabel),
        ],
      );

  Widget _label(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: AppColors.white40, size: 13),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.sectionLabel),
        ],
      );
}

//Hourly Strip 

class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.slots});
  final List<ForecastSlot> slots;

  @override
  Widget build(BuildContext context) {
    final items = slots.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Icons.schedule, 'HOURLY'),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection   : Axis.horizontal,
            padding           : EdgeInsets.zero,
            itemCount         : items.length,
            separatorBuilder  : (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final s = items[i];
              return GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child  : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i == 0 ? 'Now' : WeatherUtils.formatHour(s.dt),
                      style: AppTextStyles.cardLabel,
                    ),
                    Text(
                      WeatherUtils.conditionEmoji(s.condition),
                      style: const TextStyle(fontSize: 22),
                    ),
                    if (s.pop > 0.05)
                      Text(
                        '${(s.pop * 100).round()}%',
                        style: AppTextStyles.cardLabel.copyWith(
                            color: const Color(0xFF90CAF9)),
                      )
                    else
                      const SizedBox(height: 14),
                    Text(
                      WeatherUtils.formatTemp(s.temp),
                      style: AppTextStyles.bodyBold,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

//  5-Day Forecast
class DailyForecast extends StatelessWidget {
  const DailyForecast({super.key, required this.slots});
  final List<ForecastSlot> slots;

  List<ForecastSlot> _dailySummaries() {
    final seen = <String>{};
    final out  = <ForecastSlot>[];
    for (final s in slots) {
      final day = WeatherUtils.formatDay(s.dt);
      if (seen.add(day)) out.add(s);
      if (out.length == 5) break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final days = _dailySummaries();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Icons.calendar_today_outlined, '5-DAY FORECAST'),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child  : Column(
            children: List.generate(days.length, (i) {
              final d   = days[i];
              final day = WeatherUtils.formatDay(d.dt);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child  : Row(
                      children: [
                        Expanded(
                          flex : 3,
                          child: Text(day, style: AppTextStyles.bodyBold),
                        ),
                        Text(
                          WeatherUtils.conditionEmoji(d.condition),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        // Min/Max temp bar
                        Expanded(
                          flex : 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                WeatherUtils.formatTemp(d.tempMin),
                                style: AppTextStyles.body,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: ((d.temp - d.tempMin) /
                                            ((d.tempMax - d.tempMin)
                                                    .abs()
                                                    .clamp(1, 40)))
                                        .clamp(0.0, 1.0),
                                    backgroundColor:
                                        AppColors.white20,
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            Color(0xFFFFB74D)),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                WeatherUtils.formatTemp(d.tempMax),
                                style: AppTextStyles.bodyBold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < days.length - 1)
                    const Divider(
                        color: AppColors.glassBorder, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// Shared helpers
// (also used by SunriseSunsetCard)

Widget _sectionLabel(IconData icon, String text) => Row(
      children: [
        Icon(icon, color: AppColors.white40, size: 13),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.sectionLabel),
      ],
    );


class WeatherSkeleton extends StatefulWidget {
  const WeatherSkeleton({super.key});
  @override
  State<WeatherSkeleton> createState() => _WeatherSkeletonState();
}

class _WeatherSkeletonState extends State<WeatherSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (ctx, _) {
          final opacity = 0.06 + 0.10 * _anim.value;
          return Padding(
            padding: const EdgeInsets.all(20),
            child  : Column(
              children: [
                const SizedBox(height: 60),
                _bone(h: 28, w: 180, opacity: opacity),
                const SizedBox(height: 12),
                _bone(h: 90, w: 130, opacity: opacity),
                const SizedBox(height: 24),
                _bone(h: 100, opacity: opacity),
                const SizedBox(height: 12),
                _bone(h: 100, opacity: opacity),
                const SizedBox(height: 12),
                _bone(h: 80, opacity: opacity),
              ],
            ),
          );
        },
      );

  Widget _bone({required double h, double? w, required double opacity}) =>
      Container(
        height      : h,
        width       : w,
        margin      : const EdgeInsets.symmetric(vertical: 2),
        decoration  : BoxDecoration(
          color       : Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(14),
        ),
      );
}

// cannot find certrain city / error fetching data
class WeatherErrorView extends StatelessWidget {
  const WeatherErrorView({super.key, required this.message, required this.onRetry});
  final String   message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child  : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                message,
                style    : AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onRetry,
                icon : const Icon(Icons.refresh, color: AppColors.accent),
                label: Text('Retry',
                    style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.accent)),
              ),
            ],
          ),
        ),
      );
}
