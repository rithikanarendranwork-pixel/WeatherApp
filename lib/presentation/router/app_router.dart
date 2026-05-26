import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/saved_cities_screen.dart';

// routes between screens.

abstract final class AppRoutes {
  static const home         = '/';
  static const detail       = '/detail';
  static const search       = '/search';
  static const savedCities  = '/saved';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (ctx, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.detail,
        builder: (ctx, state) => const DetailScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (ctx, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.savedCities,
        builder: (ctx, state) => const SavedCitiesScreen(),
      ),
    ],
  );
});
