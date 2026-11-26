import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/providers.dart';
import 'core/auth/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();

  // Initialize push (Firebase, token, channels, foreground, deep-links).
  container.read(pushServiceProvider).init();

  // Re-register the device token whenever the user becomes authenticated.
  container.listen<AuthState>(authControllerProvider, (prev, next) {
    if (next.isAuthenticated && (prev?.isAuthenticated != true)) {
      container.read(pushServiceProvider).registerCurrent();
    }
  });

  runApp(UncontrolledProviderScope(container: container, child: WexApp()));
}
