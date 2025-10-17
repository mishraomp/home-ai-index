import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/screens/home/home_screen.dart';
import 'package:home_ai_index/presentation/screens/item_details_screen.dart';
import 'package:home_ai_index/presentation/screens/settings_screen.dart';
import 'package:provider/provider.dart';

/// App routing configuration using go_router
///
/// Provides declarative routing with proper deep link support
class AppRouter {
  /// Creates the GoRouter instance with all route configurations
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/item/:id',
          name: 'item-details',
          builder: (context, state) {
            final itemId = state.pathParameters['id']!;

            // Get repositories from Provider context
            final itemRepository = Provider.of<ItemRepository>(
              context,
              listen: false,
            );
            final locationHistoryRepository =
                Provider.of<LocationHistoryRepository>(context, listen: false);
            final categoryRepository = Provider.of<CategoryRepository>(
              context,
              listen: false,
            );
            final locationRepository = Provider.of<LocationRepository>(
              context,
              listen: false,
            );

            return ItemDetailsScreen(
              itemId: itemId,
              itemRepository: itemRepository,
              locationHistoryRepository: locationHistoryRepository,
              categoryRepository: categoryRepository,
              locationRepository: locationRepository,
            );
          },
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Error: ${state.error}'))),
    );
  }
}
