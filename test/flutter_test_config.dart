import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final w in ['Regular', 'Medium', 'Bold', 'ExtraBold']) {
    final loader = FontLoader('Tajawal');
    loader.addFont(Future.value(
        File('assets/fonts/Tajawal-$w.ttf').readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }
  await testMain();
}
