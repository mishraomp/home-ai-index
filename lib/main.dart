import 'package:flutter/material.dart';
import 'package:home_ai_index/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Entry point for Home AI Index application
///
/// Initializes the app with:
/// - Provider state management
/// - Material Design 3 theming
/// - Navigation routing
void main() {
  runApp(const HomeAIIndexApp());
}

/// Root application widget
///
/// Sets up Provider for state management and MaterialApp with theme configuration.
class HomeAIIndexApp extends StatelessWidget {
  const HomeAIIndexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: const [
        // Providers will be added here as we implement ViewModels
        // Example:
        // ChangeNotifierProvider(create: (_) => HomeViewModel()),
        // ChangeNotifierProvider(create: (_) => AddItemViewModel()),
      ],
      child: MaterialApp(
        title: 'Home AI Index',
        debugShowCheckedModeBanner: false,

        // Material Design 3 themes
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const PlaceholderHomeScreen(),

        // Named routes will be added here as screens are implemented
        // routes: {
        //   '/add-item': (context) => const AddItemScreen(),
        //   '/item-details': (context) => const ItemDetailsScreen(),
        //   '/locations': (context) => const LocationsScreen(),
        //   '/search': (context) => const SearchScreen(),
        // },
      ),
    );
  }
}

/// Placeholder home screen for Phase 1
///
/// Displays a welcome message to verify the app setup is complete.
/// Will be replaced with the actual HomeScreen in Phase 6 (User Story 4).
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Home AI Index')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 120,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Home AI Index',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Smart Home Inventory Manager',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Phase 1: Setup Complete',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('✓ Flutter project initialized'),
                      const Text('✓ Dependencies installed'),
                      const Text('✓ Project structure created'),
                      const Text('✓ Material Design 3 theme configured'),
                      const Text('✓ Provider state management ready'),
                      const SizedBox(height: 16),
                      Text(
                        'Next: Phase 2 - Foundational Infrastructure',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
