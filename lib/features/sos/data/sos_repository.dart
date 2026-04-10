import 'package:dio/dio.dart';

import 'sos_dto.dart';

abstract class SosRepository {
  Future<CreateSosResponse> createSos(CreateSosRequest body);
}

/// Реальный вызов API или демо без сервера (`MOCK_SOS=true` по умолчанию).
class SosRepositoryImpl implements SosRepository {
  SosRepositoryImpl(this._dio);

  final Dio _dio;

  static const bool _mock =
      bool.fromEnvironment('MOCK_SOS', defaultValue: false);

  @override
  Future<CreateSosResponse> createSos(CreateSosRequest body) async {
    if (_mock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return CreateSosResponse(
        incidentId: 'demo-${body.clientRequestId ?? 'local'}',
      );
    }

    final res = await _dio.post<Map<String, dynamic>>(
      '/alerts/sos',
      data: body.toJson(),
    );
    final data = res.data;
    if (data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Empty response',
      );
    }
    return CreateSosResponse.fromJson(data);
  }
}
