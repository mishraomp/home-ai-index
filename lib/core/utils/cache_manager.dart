import 'dart:async';

import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';

/// In-memory cache for frequently accessed data
///
/// Implements LRU (Least Recently Used) caching with configurable TTL
class CacheManager {
  CacheManager({
    this.defaultTTL = const Duration(minutes: 5),
    this.maxCacheSize = 100,
  });

  final Duration defaultTTL;
  final int maxCacheSize;

  final Map<String, _CacheEntry<dynamic>> _cache = {};
  final List<String> _accessOrder = [];

  /// Get cached value by key
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired()) {
      remove(key);
      return null;
    }

    // Update access order (move to front)
    _accessOrder.remove(key);
    _accessOrder.insert(0, key);

    return entry.value as T?;
  }

  /// Put value in cache with optional TTL
  void put<T>(String key, T value, {Duration? ttl}) {
    // Remove old entry if exists
    remove(key);

    // Evict LRU entry if cache is full
    if (_cache.length >= maxCacheSize) {
      _evictLRU();
    }

    // Add new entry
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTTL),
    );
    _accessOrder.insert(0, key);
  }

  /// Remove entry from cache
  void remove(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired())
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      remove(key);
    }
  }

  /// Get cache statistics
  CacheStats getStats() {
    return CacheStats(
      totalEntries: _cache.length,
      maxSize: maxCacheSize,
      expiredEntries: _cache.values.where((e) => e.isExpired()).length,
    );
  }

  void _evictLRU() {
    if (_accessOrder.isEmpty) return;
    final lruKey = _accessOrder.last;
    remove(lruKey);
  }
}

/// Cache entry with expiration
class _CacheEntry<T> {
  _CacheEntry({required this.value, required this.expiresAt});

  final T value;
  final DateTime expiresAt;

  bool isExpired() => DateTime.now().isAfter(expiresAt);
}

/// Cache statistics
class CacheStats {
  CacheStats({
    required this.totalEntries,
    required this.maxSize,
    required this.expiredEntries,
  });

  final int totalEntries;
  final int maxSize;
  final int expiredEntries;

  double get usagePercentage => (totalEntries / maxSize) * 100;
}

/// Specialized caches for app data
class AppCache {
  AppCache() {
    _categoriesCache = CacheManager(
      defaultTTL: const Duration(hours: 1), // Categories rarely change
      maxCacheSize: 20,
    );

    _recentItemsCache = CacheManager(
      defaultTTL: const Duration(minutes: 2), // Items change frequently
      maxCacheSize: 50,
    );

    _locationCache = CacheManager(
      defaultTTL: const Duration(minutes: 10),
      maxCacheSize: 30,
    );

    // Start periodic cleanup
    _startPeriodicCleanup();
  }

  late final CacheManager _categoriesCache;
  late final CacheManager _recentItemsCache;
  late final CacheManager _locationCache;
  Timer? _cleanupTimer;

  // Category cache methods
  List<Category>? getCachedCategories() {
    return _categoriesCache.get<List<Category>>('categories');
  }

  void cacheCategories(List<Category> categories) {
    _categoriesCache.put('categories', categories);
  }

  Category? getCachedCategory(String id) {
    return _categoriesCache.get<Category>('category_$id');
  }

  void cacheCategory(Category category) {
    _categoriesCache.put('category_${category.id}', category);
  }

  // Recent items cache methods
  List<Item>? getCachedRecentItems({int limit = 10}) {
    return _recentItemsCache.get<List<Item>>('recent_$limit');
  }

  void cacheRecentItems(List<Item> items, {int limit = 10}) {
    _recentItemsCache.put('recent_$limit', items);
  }

  // Location cache methods
  dynamic getCachedLocation(String key) {
    return _locationCache.get(key);
  }

  void cacheLocation(String key, dynamic value) {
    _locationCache.put(key, value);
  }

  // Clear all caches
  void clearAll() {
    _categoriesCache.clear();
    _recentItemsCache.clear();
    _locationCache.clear();
  }

  // Get overall cache stats
  Map<String, CacheStats> getAllStats() {
    return {
      'categories': _categoriesCache.getStats(),
      'recentItems': _recentItemsCache.getStats(),
      'locations': _locationCache.getStats(),
    };
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _categoriesCache.clearExpired();
      _recentItemsCache.clearExpired();
      _locationCache.clearExpired();
    });
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    clearAll();
  }
}
