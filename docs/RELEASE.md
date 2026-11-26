# Releasing the Wex app (Android)

## Builds
- CI (`.github/workflows/ci.yml`) runs `flutter analyze` + `flutter test` on every push.
- The **APK build** runs only on a `v*` tag or a manual `workflow_dispatch`, and uploads
  `wex-app-apk` (a `--release` APK on tags).
- Build on the phone is intentionally avoided (gradle OOMs 4GB); builds run in CI.

## Cut a release
```
# bump version in pubspec.yaml (e.g. 1.0.0+1 -> 1.0.1+2), commit
git tag v1.0.1 && git push --tags       # triggers the release APK build
gh run download <run-id> -n wex-app-apk # fetch app-release.apk
```

## Play Store signing (when ready)
The CI release APK is signed with a debug key (installable, NOT Play-ready). To ship to Play:
1. Create an upload keystore: `keytool -genkey -v -keystore wex-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`.
2. Add `android/key.properties` (gitignored) with the store/key passwords and alias.
3. Wire `signingConfigs.release` in `android/app/build.gradle.kts` to read `key.properties`.
4. Store the keystore + passwords as GitHub secrets and decode them in a release job, then
   `flutter build appbundle --release` and upload the `.aab` to Play.

## Config
- App id: `com.wextechnology.wex_app`; display name: «ويكس تكنولوجي».
- API origin via `--dart-define=WEX_ORIGIN=https://wex-technology.com` (default baked in).
- Launcher icon: `assets/icon/app_icon.png` (brand mark), navy adaptive background.
- Push: see `docs/PUSH_SETUP.md` (needs `google-services.json`).
