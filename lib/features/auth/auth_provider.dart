import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';

class AuthState {
  const AuthState({
    this.token,
    this.userId,
    this.email,
    this.role,
    this.orgId,
    this.userType,
  });

  final String? token;
  final String? userId;
  final String? email;
  final String? role;
  final String? orgId;
  final String? userType;

  bool get isLoggedIn => token != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._dio) : super(const AuthState());

  final Dio _dio;

  Future<void> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data!;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['accessToken'] as String;

    _dio.options.headers['Authorization'] = 'Bearer $token';

    state = AuthState(
      token: token,
      userId: user['id'] as String,
      email: user['email'] as String,
      role: user['role'] as String,
      orgId: user['orgId'] as String,
      userType: user['userType'] as String,
    );
  }

  void logout() {
    _dio.options.headers.remove('Authorization');
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(dioProvider));
});
