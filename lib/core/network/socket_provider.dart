import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/auth/auth_provider.dart';
import 'dio_provider.dart';

final socketProvider = Provider<IO.Socket?>((ref) {
  final auth = ref.watch(authProvider);
  if (!auth.isLoggedIn || auth.token == null) return null;

  final dio = ref.read(dioProvider);
  final baseUrl = dio.options.baseUrl;

  final socket = IO.io(
    baseUrl,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': auth.token!})
        .build(),
  );

  socket.connect();

  ref.onDispose(() {
    socket.disconnect();
    socket.dispose();
  });

  return socket;
});
