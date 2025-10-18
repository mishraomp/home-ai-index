import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Banner to warn users about low storage space
class StorageWarningBanner extends StatelessWidget {
  const StorageWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasEnoughStorage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasData && !snapshot.data!) {
          return MaterialBanner(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            leading: Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            content: Text(
              'Storage space is low. Please free up space to continue adding items.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: Text(
                  'Dismiss',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<bool> _hasEnoughStorage() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dirStat = await appDir.stat();

      // Estimate available storage by checking directory size
      // Note: This is a simplified check. For production, consider using
      // the disk_space package for more accurate free space detection.
      const minStorageBytes = 100 * 1024 * 1024; // 100 MB

      // If directory is very large, storage might be running low
      // This is a heuristic, not precise measurement
      return dirStat.size < minStorageBytes * 10;
    } catch (e) {
      // If check fails, assume enough storage
      return true;
    }
  }

  /// Check if storage is critically low (for external use)
  static Future<bool> checkStorageStatus() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dirStat = await appDir.stat();
      const minStorageBytes = 100 * 1024 * 1024; // 100 MB
      return dirStat.size < minStorageBytes * 10;
    } catch (e) {
      return true; // Assume OK if check fails
    }
  }
}
