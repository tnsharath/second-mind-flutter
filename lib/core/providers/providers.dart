import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/env.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';
import '../services/secure_storage_service.dart';
import '../services/speech_service.dart';
import '../services/websocket_service.dart';

/// Overridden in main() with the already-initialized instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final secureStorageProvider = Provider<AuraSecureStorage>(
  (ref) => AuraSecureStorage(),
);

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(secureStorageProvider).readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

final webSocketServiceProvider = Provider<WebSocketService>(
  (ref) => WebSocketService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final speechServiceProvider = Provider<SpeechService>(
  (ref) => SpeechService(),
);

/// Live connectivity stream; empty list entries of [ConnectivityResult.none]
/// mean the device is offline.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) => Connectivity().onConnectivityChanged,
);
