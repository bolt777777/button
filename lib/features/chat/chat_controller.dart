import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.at,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime at;
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController();
});

/// Локальный чат с демо-ответами оператора (без бэкенда).
class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController() : super(const []);

  static const _uuid = Uuid();

  /// Первое сообщение от оператора (вызывать при открытии экрана).
  void ensureWelcome(String welcomeText) {
    if (state.isNotEmpty) return;
    state = [
      ChatMessage(
        id: _uuid.v4(),
        text: welcomeText,
        isUser: false,
        at: DateTime.now(),
      ),
    ];
  }

  Future<void> send(
    String raw, {
    required String demoReply,
  }) async {
    final text = raw.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      at: DateTime.now(),
    );
    state = [...state, userMsg];

    await Future<void>.delayed(const Duration(milliseconds: 700));
    final reply = ChatMessage(
      id: _uuid.v4(),
      text: demoReply,
      isUser: false,
      at: DateTime.now(),
    );
    state = [...state, reply];
  }
}
