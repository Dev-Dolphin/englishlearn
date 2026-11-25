import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

final apiClientProvider = Provider<OfflineCapableApiClient>((ref) {
  return const OfflineCapableApiClient();
});

/// Lightweight zero-dependency client ready for future Cloud Sync while running 100% Offline-first.
class OfflineCapableApiClient {
  const OfflineCapableApiClient();

  String get baseUrl => AppConfig.apiBaseUrl;
  bool get isOfflineFirstEnabled => true;
}
