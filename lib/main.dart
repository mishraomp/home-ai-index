import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:home_ai_index/core/theme/app_theme.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/category_repository_impl.dart';
import 'package:home_ai_index/data/repositories/image_repository.dart';
import 'package:home_ai_index/data/repositories/image_repository_impl.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository_impl.dart';
import 'package:home_ai_index/data/services/image_recognition_service.dart';
import 'package:home_ai_index/data/services/image_recognition_service_impl.dart';
import 'package:home_ai_index/presentation/screens/home_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/add_item_viewmodel.dart';

/// Entry point for Home AI Index application
///
/// Initializes the app with:
/// - Database and repositories
/// - Provider state management
/// - Material Design 3 theming
/// - Navigation routing
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseHelper = DatabaseHelper.instance;
  await databaseHelper.database; // Ensure database is created

  // Initialize repositories
  final itemRepository = ItemRepositoryImpl(databaseHelper);
  final categoryRepository = CategoryRepositoryImpl(databaseHelper);
  final imageRepository = ImageRepositoryImpl();

  // Initialize ML service
  final recognitionService = await ImageRecognitionServiceImpl.create(
    'assets/ml_models/mobilenet_v2.tflite',
  );

  runApp(HomeAIIndexApp(
    itemRepository: itemRepository,
    categoryRepository: categoryRepository,
    imageRepository: imageRepository,
    recognitionService: recognitionService,
  ));
}

/// Root application widget
///
/// Sets up Provider for state management and MaterialApp with theme configuration.
class HomeAIIndexApp extends StatelessWidget {
  final ItemRepositoryImpl itemRepository;
  final CategoryRepositoryImpl categoryRepository;
  final ImageRepositoryImpl imageRepository;
  final ImageRecognitionServiceImpl recognitionService;

  const HomeAIIndexApp({
    super.key,
    required this.itemRepository,
    required this.categoryRepository,
    required this.imageRepository,
    required this.recognitionService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository providers - Register by interface type
        Provider<ItemRepository>.value(value: itemRepository),
        Provider<CategoryRepository>.value(value: categoryRepository),
        Provider<ImageRepository>.value(value: imageRepository),
        Provider<ImageRecognitionService>.value(value: recognitionService),

        // ViewModel providers
        ChangeNotifierProvider(
          create: (_) => AddItemViewModel(
            itemRepository: itemRepository,
            categoryRepository: categoryRepository,
            imageRepository: imageRepository,
            recognitionService: recognitionService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Home AI Index',
        debugShowCheckedModeBanner: false,

        // Material Design 3 themes
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
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
