import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_theme.dart';
import '../../domain/entities/weather_entity.dart';
import '../providers/app_providers.dart';
import '../widgets/weather_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl   = TextEditingController();
  final _focus  = FocusNode();
  Timer? _debounce;

  // Inline preview state
  AsyncValue<WeatherEntity>? _preview;

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _preview = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(value.trim()));
  }

  Future<void> _search(String city) async {
    setState(() => _preview = const AsyncValue.loading());
    try {
      final useCase = ref.read(getCurrentWeatherProvider);
      final result  = await useCase(city);
      if (mounted) setState(() => _preview = AsyncValue.data(result));
    } catch (e, st) {
      if (mounted) setState(() => _preview = AsyncValue.error(e, st));
    }
  }
  void _selectCity(String city) {
    ref.read(activeCityProvider.notifier).state = city;
    // Invalidate so fresh data is fetched
    ref.invalidate(currentWeatherProvider);
    ref.invalidate(forecastProvider);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WeatherGradientBackground(
      condition: 'Clear',
      child    : Scaffold(
        backgroundColor: Colors.transparent,
        body           : SafeArea(
          child: Column(
            children: [
                // Search bar with inline preview
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child  : Row(
                  children: [
                    IconButton(
                      icon     : const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color       : AppColors.glass,
                          borderRadius: BorderRadius.circular(30),
                          border      : Border.all(
                              color: AppColors.glassBorder),
                        ),
                        child: TextField(
                          controller : _ctrl,
                          focusNode  : _focus,
                          style      : AppTextStyles.bodyBold,
                          decoration : InputDecoration(
                            hintText       : 'Search city…',
                            hintStyle      : AppTextStyles.searchHint,
                            prefixIcon     : const Icon(Icons.search,
                                color: AppColors.white40, size: 20),
                            suffixIcon     : _ctrl.text.isNotEmpty
                                ? IconButton(
                                    icon     : const Icon(Icons.clear,
                                        color: AppColors.white40, size: 18),
                                    onPressed: () {
                                      _ctrl.clear();
                                      setState(() => _preview = null);
                                    },
                                  )
                                : null,
                            border         : InputBorder.none,
                            contentPadding :
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged  : (v) {
                            setState(() {});  
                            _onChanged(v);
                          },
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) _search(v.trim());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_preview == null) return _suggestedCities();

    return _preview!.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white54)),
      error  : (e, _) => WeatherErrorView(
        message : e.toString().replaceFirst('Exception: ', ''),
        onRetry : () => _search(_ctrl.text.trim()),
      ),
      data   : (weather) => _PreviewCard(
        weather   : weather,
        onSelect  : () => _selectCity(weather.cityName),
      ),
    );
  }

  Widget _suggestedCities() {
    final suggestions = [
      'New York', 'London', 'Tokyo', 'Sydney',
      'Paris', 'Dubai', 'Toronto', 'Mumbai',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child  : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('POPULAR CITIES', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          Wrap(
            spacing    : 8,
            runSpacing : 8,
            children   : suggestions.map((city) {
              return GestureDetector(
                onTap  : () => _selectCity(city),
                child  : GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  radius : 30,
                  child  : Text(city, style: AppTextStyles.bodyBold),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.weather, required this.onSelect});
  final WeatherEntity weather;
  final VoidCallback  onSelect;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child  : GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(weather.cityName,
                            style: AppTextStyles.cityName),
                        Text(weather.country,
                            style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  Text(
                    '${weather.temp.round()}°',
                    style: AppTextStyles.tempHero(48),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(weather.description,
                      style: AppTextStyles.body),
                  const Spacer(),
                  Text(
                    'H:${weather.tempMax.round()}° '
                    'L:${weather.tempMin.round()}°',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width : double.infinity,
                child : ElevatedButton(
                  style    : ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyDay,
                    foregroundColor: Colors.white,
                    shape          : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onSelect,
                  child    : Text('View ${weather.cityName}',
                      style: AppTextStyles.bodyBold),
                ),
              ),
            ],
          ),
        ),
      );
}
