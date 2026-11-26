// Hand-written from android/app/google-services.json (Android-only app).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for Firebase in this app.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Only Android is configured for Firebase.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTlUq9YNR-hp-RkvKgHddpRV9L6-DDNAY',
    appId: '1:106015853692:android:6de37eb1d6afb751da0df9',
    messagingSenderId: '106015853692',
    projectId: 'com-almhdy24-nabd',
    storageBucket: 'com-almhdy24-nabd.firebasestorage.app',
  );
}
