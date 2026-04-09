import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorWidgetBuilder();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async: $error');
    debugPrint('$stack');
    return true;
  };
  runZonedGuarded(
    () => runApp(const ProviderScope(child: BodyguardApp())),
    (error, stack) {
      debugPrint('Zone error: $error');
      debugPrint('$stack');
    },
  );
}

/// Вместо «белого экрана» при ошибке в дереве виджетов показываем текст (в debug — полный лог).
void _installErrorWidgetBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return Material(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              'Ошибка отрисовки:\n\n'
              '${details.exceptionAsString()}\n\n'
              '${details.stack}',
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ),
        ),
      );
    }
    return Material(
      color: const Color(0xFFF2F2F7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Не удалось отобразить экран. Закройте приложение и откройте снова.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
          ),
        ),
      ),
    );
  };
}

class BodyguardApp extends StatelessWidget {
  const BodyguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) =>
          AppLocalizations.of(ctx)?.appTitle ?? 'Bodyguard',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('en');
      },
      theme: buildAppTheme(),
      // Подложка на случай задержки первого кадра (совпадает с фоном темы).
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFFF2F2F7),
          child: child ?? const SizedBox.shrink(),
        );
      },
      // Диагностика «белого экрана» на устройстве: если виден синий «Загрузка…», движок рисует;
      // если сразу белый — нативный/Impeller; если синий → белый — сбой в HomeScreen/провайдерах.
      home: const _BootSplash(),
    );
  }
}

class _BootSplash extends StatefulWidget {
  const _BootSplash();

  @override
  State<_BootSplash> createState() => _BootSplashState();
}

class _BootSplashState extends State<_BootSplash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Короткая пауза, чтобы на устройстве был заметен кадр с синим фоном (диагностика).
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D47A1),
      body: Center(
        child: Text(
          'Загрузка…',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
