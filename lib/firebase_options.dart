import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjK-UunmV3bSoAkaai48w55rbavogxAHE',
    appId: '1:903915356477:web:a7c92a4b612fa2cb118554',
    messagingSenderId: '903915356477',
    projectId: 'kaspi-e5b1c',
    storageBucket: 'kaspi-e5b1c.firebasestorage.app',
    authDomain: 'kaspi-e5b1c.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCaX4PuZelzhvN66lpK_KSxtD2qJPixR-0',
    appId: '1:903915356477:android:cd0cc73a9717a0a4118554',
    messagingSenderId: '903915356477',
    projectId: 'kaspi-e5b1c',
    storageBucket: 'kaspi-e5b1c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: '903915356477',
    projectId: 'kaspi-e5b1c',
    storageBucket: 'kaspi-e5b1c.firebasestorage.app',
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.kaspi',
    ),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_MACOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: '903915356477',
    projectId: 'kaspi-e5b1c',
    storageBucket: 'kaspi-e5b1c.firebasestorage.app',
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.kaspi',
    ),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WINDOWS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: '903915356477',
    projectId: 'kaspi-e5b1c',
    storageBucket: 'kaspi-e5b1c.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_LINUX_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_LINUX_APP_ID'),
    messagingSenderId: '903915356477',
    projectId: 'kaspi-e5b1c',
    storageBucket: 'kaspi-e5b1c.firebasestorage.app',
  );

  static bool get webIsConfigured =>
      web.apiKey.isNotEmpty && web.appId.isNotEmpty;

  static bool get iosIsConfigured =>
      ios.apiKey.isNotEmpty && ios.appId.isNotEmpty;

  static bool get macosIsConfigured =>
      macos.apiKey.isNotEmpty && macos.appId.isNotEmpty;

  /// Web OAuth client ID (Firebase Console → Authentication → Google).
  static const String googleWebClientId =
      '903915356477-fbgh3uilsmmsk026e80l1t6a95vcc3ni.apps.googleusercontent.com';
}
