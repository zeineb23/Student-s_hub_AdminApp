// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHrBWX-vciCS4KgKPQHjMp7waSdMKuUrw',
    appId: '1:427799045150:web:ff745a479b17054e1a7a0f',
    messagingSenderId: '427799045150',
    projectId: 'studentshub-54ac7',
    authDomain: 'studentshub-54ac7.firebaseapp.com',
    storageBucket: 'studentshub-54ac7.appspot.com',
    measurementId: 'G-YT9Y1MDJTY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0iv5uLyhWz34TCj8OnA6tJJ4Yerga4jQ',
    appId: '1:427799045150:android:02b0eed6ec5de1111a7a0f',
    messagingSenderId: '427799045150',
    projectId: 'studentshub-54ac7',
    storageBucket: 'studentshub-54ac7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCl265W-s3WY73ZS_FbHgFp6ideoWawDA',
    appId: '1:427799045150:ios:cc94a14e65e85adf1a7a0f',
    messagingSenderId: '427799045150',
    projectId: 'studentshub-54ac7',
    storageBucket: 'studentshub-54ac7.appspot.com',
    iosBundleId: 'com.example.flutterApplication6',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDCl265W-s3WY73ZS_FbHgFp6ideoWawDA',
    appId: '1:427799045150:ios:cc94a14e65e85adf1a7a0f',
    messagingSenderId: '427799045150',
    projectId: 'studentshub-54ac7',
    storageBucket: 'studentshub-54ac7.appspot.com',
    iosBundleId: 'com.example.flutterApplication6',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBHrBWX-vciCS4KgKPQHjMp7waSdMKuUrw',
    appId: '1:427799045150:web:79d20199ad064c4f1a7a0f',
    messagingSenderId: '427799045150',
    projectId: 'studentshub-54ac7',
    authDomain: 'studentshub-54ac7.firebaseapp.com',
    storageBucket: 'studentshub-54ac7.appspot.com',
    measurementId: 'G-NKEC1MVB8V',
  );
}
