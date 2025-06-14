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
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNJcfQ4g-TM-uGt0-bCxz7Ch3f7bra9pg',
    appId: '1:949152926855:android:2a0c6551345bd8757f7c22',
    messagingSenderId: '949152926855',
    projectId: 'anam-42579',
    storageBucket: 'anam-42579.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0JXEpVHxMnzE2GQkLJGXyu0MyGS4p0Ak',
    appId: '1:949152926855:ios:dfdcfcb6f9614c227f7c22',
    messagingSenderId: '949152926855',
    projectId: 'anam-42579',
    storageBucket: 'anam-42579.appspot.com',
    iosBundleId: 'com.ban3am',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPa93HFoFjuHxtKL4iyz_6vUKu5wnzyhg',
    appId: '1:949152926855:web:9c6db1983043ea8a7f7c22',
    messagingSenderId: '949152926855',
    projectId: 'anam-42579',
    authDomain: 'anam-42579.firebaseapp.com',
    storageBucket: 'anam-42579.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD0JXEpVHxMnzE2GQkLJGXyu0MyGS4p0Ak',
    appId: '1:949152926855:ios:dfdcfcb6f9614c227f7c22',
    messagingSenderId: '949152926855',
    projectId: 'anam-42579',
    storageBucket: 'anam-42579.appspot.com',
    iosBundleId: 'com.ban3am',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCPa93HFoFjuHxtKL4iyz_6vUKu5wnzyhg',
    appId: '1:949152926855:web:b3b58fdb81df5bd97f7c22',
    messagingSenderId: '949152926855',
    projectId: 'anam-42579',
    authDomain: 'anam-42579.firebaseapp.com',
    storageBucket: 'anam-42579.appspot.com',
  );

}