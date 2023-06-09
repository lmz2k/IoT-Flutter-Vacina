// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcWdnO4bmLH15I6RaVJtP-hA5jFzQ8QJ8',
    appId: '1:390803522274:web:a6680e7dbd0fae20c694bb',
    messagingSenderId: '390803522274',
    projectId: 'esp32-firebase-temp-31c09',
    authDomain: 'esp32-firebase-temp-31c09.firebaseapp.com',
    databaseURL: 'https://esp32-firebase-temp-31c09-default-rtdb.firebaseio.com',
    storageBucket: 'esp32-firebase-temp-31c09.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAye7B312AwhksqSJ80irUAZI1Lrc1CY0o',
    appId: '1:390803522274:android:bc724a2511b7164ec694bb',
    messagingSenderId: '390803522274',
    projectId: 'esp32-firebase-temp-31c09',
    databaseURL: 'https://esp32-firebase-temp-31c09-default-rtdb.firebaseio.com',
    storageBucket: 'esp32-firebase-temp-31c09.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCslKZtg3o6HGzwV19HDjzO_oewaNVKZ7c',
    appId: '1:390803522274:ios:f1a7c06d59ca2510c694bb',
    messagingSenderId: '390803522274',
    projectId: 'esp32-firebase-temp-31c09',
    databaseURL: 'https://esp32-firebase-temp-31c09-default-rtdb.firebaseio.com',
    storageBucket: 'esp32-firebase-temp-31c09.appspot.com',
    androidClientId: '390803522274-40mcbns82390b1l5mc97m0c9a5iotmpe.apps.googleusercontent.com',
    iosClientId: '390803522274-g5ujhva2m7muqko06jsaph7ikihlnea2.apps.googleusercontent.com',
    iosBundleId: 'com.example.vacIot',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCslKZtg3o6HGzwV19HDjzO_oewaNVKZ7c',
    appId: '1:390803522274:ios:f1a7c06d59ca2510c694bb',
    messagingSenderId: '390803522274',
    projectId: 'esp32-firebase-temp-31c09',
    databaseURL: 'https://esp32-firebase-temp-31c09-default-rtdb.firebaseio.com',
    storageBucket: 'esp32-firebase-temp-31c09.appspot.com',
    androidClientId: '390803522274-40mcbns82390b1l5mc97m0c9a5iotmpe.apps.googleusercontent.com',
    iosClientId: '390803522274-g5ujhva2m7muqko06jsaph7ikihlnea2.apps.googleusercontent.com',
    iosBundleId: 'com.example.vacIot',
  );
}
