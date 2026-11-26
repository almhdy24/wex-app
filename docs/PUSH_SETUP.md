# Enabling native push (FCM) — Wex app

The app ships with all push plumbing ready: `PushRepository` (registers the device
token at `POST /push/subscriptions` with `provider: fcm`), the preferences screen
(`GET/PUT /push/preferences`), and `PushService.registerToken`. Only the Firebase
device-token acquisition is left to wire, because it needs your Firebase project.

## One-time setup

1. Create a Firebase project; add an **Android app** with package
   `com.wextechnology.wex_app`. Download **`google-services.json`** into
   `android/app/`.
2. Add deps:
   ```
   flutter pub add firebase_core firebase_messaging flutter_local_notifications
   ```
   Then add the Google-services Gradle plugin (FlutterFire's `flutterfire configure`
   does this and generates `lib/firebase_options.dart`).
3. In `main()`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   final token = await FirebaseMessaging.instance.getToken();
   if (token != null) await PushService(container.read(pushRepositoryProvider)).registerToken(token, deviceLabel: '...');
   FirebaseMessaging.instance.onTokenRefresh.listen((t) => PushService(...).registerToken(t));
   ```
4. Register 3 Android notification channels matching the backend's
   `FcmProvider` routing: **`payments`**, **`orders`**, **`offers`**. Read
   `message.data['type']`, `['url']`, `['orderNumber']` and deep-link with
   go_router (`/orders/:number`, `/products/:slug`, `/notifications`).
5. Android 13+: request the `POST_NOTIFICATIONS` runtime permission.

## Backend (env-only — already built)

`wex-api` already contains a complete `FcmProvider`. Enable it in `.env`:
```
FCM_ENABLED=true
FCM_SERVICE_ACCOUNT_PATH=_wex_core/writable/fcm-service-account.json
FCM_PROJECT_ID=<your-firebase-project-id>
```
Upload the Firebase **service-account JSON** (Project settings → Service accounts →
Generate new private key) to that writable path. Delivery then flows through the
existing push outbox + cron. No backend code changes.
