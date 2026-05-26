import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_theme.dart';
import '../../core/utils/weather_utils.dart';
import '../providers/app_providers.dart';
import '../widgets/weather_widgets.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync  = ref.watch(currentWeatherProvider);
    final forecastAsync = ref.watch(forecastProvider);

    return weatherAsync.when(
      loading : () => const _DetailScaffold(
          condition: 'Clear', child: WeatherSkeleton()),
      error   : (e, _) => _DetailScaffold(
        condition: 'Clouds',
        child    : WeatherErrorView(
          message : e.toString(),
          onRetry : () => ref.invalidate(currentWeatherProvider),
        ),
      ),
      data: (weather) => _DetailScaffold(
        condition: weather.condition,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor        : Colors.transparent,
              floating               : true,
              title                  : Text(weather.fullLocation,
                  style: AppTextStyles.cityName),
              iconTheme              : const IconThemeData(color: Colors.white),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver : SliverList(
                delegate: SliverChildListDelegate([
                  // Mini hero
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          WeatherUtils.conditionEmoji(weather.condition),
                          style: const TextStyle(fontSize: 64),
                        ),
                        Text(WeatherUtils.formatTemp(weather.temp),
                            style: AppTextStyles.tempHero(72)),
                        Text(weather.description.toUpperCase(),
                            style: AppTextStyles.condition),
                        const SizedBox(height: 4),
                        Text(
                          WeatherUtils.formatDate(weather.dt),
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  WeatherStatsGrid(weather: weather),
                  const SizedBox(height: 20),
                  SunriseSunsetCard(weather: weather),
                  const SizedBox(height: 20),
                  forecastAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error  : (_, __) => const SizedBox.shrink(),
                    data   : (s) => Column(
                      children: [
                        HourlyStrip(slots: s),
                        const SizedBox(height: 20),
                        DailyForecast(slots: s),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Extra info card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.white40, size: 13),
                          const SizedBox(width: 6),
                          Text('MORE INFO', style: AppTextStyles.sectionLabel),
                        ]),
                        const SizedBox(height: 14),
                        _row('Coordinates',
                            '${weather.lat.toStringAsFixed(2)}°, '
                            '${weather.lon.toStringAsFixed(2)}°'),
                        _row('Cloud cover', '${weather.clouds}%'),
                        _row('Wind direction',
                            WeatherUtils.windDir(weather.windDeg)),
                        _row('Visibility',
                            WeatherUtils.formatVisibility(weather.visibility)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body),
            Text(value, style: AppTextStyles.bodyBold),
          ],
        ),
      );
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.condition, required this.child});
  final String condition;
  final Widget child;

  @override
  Widget build(BuildContext context) => WeatherGradientBackground(
        condition: condition,
        child    : Scaffold(
          backgroundColor: Colors.transparent,
          body           : SafeArea(child: child),
        ),
      );
}
