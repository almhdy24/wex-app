import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/design/theme.dart';
import 'router.dart';

class WexApp extends StatelessWidget {
  WexApp({super.key});
  final _router = appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ويكس تكنولوجي',
      debugShowCheckedModeBanner: false,
      theme: buildWexTheme(),
      routerConfig: _router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
