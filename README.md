# bhook_lagi_hain

Sample Flutter app with simple login, sign up and password recovery screens built with the Bloc state management library.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Setup

This project uses Firebase Authentication for email/password, Google, Facebook
and phone login. To configure Firebase:

1. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/). 
2. Run `flutterfire configure` inside the project to generate
   `lib/firebase_options.dart` and configure your Android and iOS apps.
3. Add the generated Firebase configuration files
   (`google-services.json` for Android and `GoogleService-Info.plist` for iOS)
   to the respective platforms.
4. Enable **Email/Password**, **Google**, **Facebook** and **Phone** sign-in
   providers in the Firebase console.
5. After configuration run `flutter pub get` and launch the app.
