import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// REST-клиент. Base URL задаётся через `--dart-define=API_BASE_URL=...`.
final dioProvider = Provider<Dio>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (e, handler) {
        handler.next(e);
      },
    ),
  );

  ref.onDispose(dio.close);
  return dio;
});
