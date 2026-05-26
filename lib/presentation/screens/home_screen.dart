import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_theme.dart';
import '../../core/utils/weather_utils.dart';
import '../providers/app_providers.dart';
import '../router/app_router.dart';
import '../widgets/weather_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final forecastAsync = ref.watch(forecastProvider);

    return weatherAsync.when(
      loading: () => WeatherGradientBackground(
        condition: 'Clear',
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: WeatherSkeleton()),
        ),
      ),
      error: (e, _) => WeatherGradientBackground(
        condition: 'Clouds',
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: WeatherErrorView(
              message : e.toString().replaceFirst('Exception: ', ''),
              onRetry : () => ref.invalidate(currentWeatherProvider),
            ),
          ),
        ),
      ),
      data: (weather) => WeatherGradientBackground(
        condition: weather.condition,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ─────────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  floating        : true,
                  automaticallyImplyLeading: false,
                  title: GestureDetector(
                    onTap: () => context.push(AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color       : AppColors.glass,
                        borderRadius: BorderRadius.circular(30),
                        border      : Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.white40, size: 18),
                          const SizedBox(width: 8),
                          Text(weather.fullLocation,
                              style: AppTextStyles.bodyBold),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.white40, size: 18),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon   : const Icon(Icons.bookmark_outline,
                          color: AppColors.white70),
                      tooltip: 'Saved cities',
                      onPressed: () => context.push(AppRoutes.savedCities),
                    ),
                  ],
                ),

                // ── Body ────────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  sliver : SliverList(
                    delegate: SliverChildListDelegate([
                      // Temperature hero
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child  : TemperatureHero(weather: weather),
                      ),

                      // "See details" chip
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.detail),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            radius : 30,
                            child  : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('See full details',
                                    style: AppTextStyles.body),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios,
                                    color: AppColors.white70, size: 12),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Hourly forecast
                      forecastAsync.when(
                        loading : () => const SizedBox.shrink(),
                        error   : (_, __) => const SizedBox.shrink(),
                        data    : (slots) => HourlyStrip(slots: slots),
                      ),

                      const SizedBox(height: 28),

                      // Stats grid
                      WeatherStatsGrid(weather: weather),

                      const SizedBox(height: 28),

                      // Sunrise / Sunset
                      SunriseSunsetCard(weather: weather),

                      const SizedBox(height: 28),

                      // 5-day forecast
                      forecastAsync.when(
                        loading : () => const SizedBox.shrink(),
                        error   : (_, __) => const SizedBox.shrink(),
                        data    : (slots) => DailyForecast(slots: slots),
                      ),

                      const SizedBox(height: 16),

                      // Last updated
                      Center(
                        child: Text(
                          'Updated ${WeatherUtils.formatTime(weather.dt)}',
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.white40),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
