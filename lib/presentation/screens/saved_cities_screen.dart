import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/weather_widgets.dart';

class SavedCitiesScreen extends ConsumerWidget {
  const SavedCitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedCitiesProvider);
    final activeCity = ref.watch(activeCityProvider);

    return WeatherGradientBackground(
      condition: 'Clear',
      child    : Scaffold(
        backgroundColor: Colors.transparent,
        body           : SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                child  : Row(
                  children: [
                    IconButton(
                      icon     : const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text('Saved Cities', style: AppTextStyles.cityName),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to search to add a city
                        Navigator.of(context).pop();
                        // Handled by HomeScreen fab / search button
                      },
                      icon : const Icon(Icons.add,
                          color: AppColors.accent, size: 20),
                      label: Text('Add',
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.accent)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── List ───────────────────────────────────────────────
              Expanded(
                child: savedAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white54)),
                  error  : (e, _) => WeatherErrorView(
                    message : e.toString(),
                    onRetry : () => ref.invalidate(savedCitiesProvider),
                  ),
                  data   : (cities) => cities.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          padding        : const EdgeInsets.all(16),
                          itemCount      : cities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder    : (ctx, i) {
                            final city      = cities[i];
                            final isActive  = city == activeCity;

                            return _CityTile(
                              city    : city,
                              isActive: isActive,
                              onTap   : () {
                                ref
                                    .read(activeCityProvider.notifier)
                                    .state = city;
                                ref.invalidate(currentWeatherProvider);
                                ref.invalidate(forecastProvider);
                                Navigator.of(context).pop();
                              },
                              onDelete: () async {
                                await ref
                                    .read(removeCityProvider)
                                    .call(city);
                                ref.invalidate(savedCitiesProvider);
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.city,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final String       city;
  final bool         isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => GlassCard(
        color : isActive
            ? AppColors.glass.withOpacity(0.25)
            : AppColors.glass,
        child : ListTile(
          contentPadding: EdgeInsets.zero,
          leading       : isActive
              ? const Icon(Icons.location_on,
                  color: AppColors.accent, size: 20)
              : const Icon(Icons.location_city,
                  color: AppColors.white40, size: 20),
          title         : Text(city, style: AppTextStyles.bodyBold),
          trailing      : IconButton(
            icon     : const Icon(Icons.delete_outline,
                color: AppColors.white40, size: 20),
            onPressed: onDelete,
          ),
          onTap         : onTap,
        ),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏙️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('No saved cities yet',
                style: AppTextStyles.cityName),
            const SizedBox(height: 8),
            Text(
              'Search for a city and save it\nto see it here.',
              style    : AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
