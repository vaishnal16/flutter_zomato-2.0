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
    // No mobile support needed, we're focusing on web only
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyDPSha9DDzBOgpPiFdfrDvC8YCuZu1XU7w",
  authDomain: "zomato-flutter-2.firebaseapp.com",
  projectId: "zomato-flutter-2",
  storageBucket: "zomato-flutter-2.firebasestorage.app",
  messagingSenderId: "534504166472",
  appId: "1:534504166472:web:ae982269c07b666321347d",
  measurementId: "G-6N2PKE8RB5"
  );
}
