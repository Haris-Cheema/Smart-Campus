// File generated manually for Firebase configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS is not configured — run flutterfire configure for iOS support.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not configured.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows is not configured.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not configured.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWJhrF-y7Ma_2mO7mMuMEzS33vnxmBuV4',
    appId: '1:84042858582:android:a40079569f7ccd11d23bf7',
    messagingSenderId: '84042858582',
    projectId: 'smart-campus-7f033',
    storageBucket: 'smart-campus-7f033.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBM9oy6K0KcWYnqPBwwix9vVvN8L5z8s5M',
    appId: '1:84042858582:android:a40079569f7ccd11d23bf7',
    messagingSenderId: '84042858582',
    projectId: 'smart-campus-7f033',
    storageBucket: 'smart-campus-7f033.firebasestorage.app',
    authDomain: 'smart-campus-7f033.firebaseapp.com',
  );
}
