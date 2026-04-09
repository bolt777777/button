import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'sos_repository.dart';

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return SosRepositoryImpl(ref.watch(dioProvider));
});
