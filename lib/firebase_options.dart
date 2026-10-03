import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase options are not configured for web.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByA7PNb43_GoeEyCcqsXV2OhNzt614zeE',
    appId: '1:900384285987:android:16e6d13efbb479dc005896',
    messagingSenderId: '900384285987',
    projectId: 'hamro-futsal-6f95c',
    storageBucket: 'hamro-futsal-6f95c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJNRKGJAAvEU30MNbwk6mgiSeRI_R6L-I',
    appId: '1:900384285987:ios:2fdce3bc99bb6488005896',
    messagingSenderId: '900384285987',
    projectId: 'hamro-futsal-6f95c',
    storageBucket: 'hamro-futsal-6f95c.firebasestorage.app',
    iosBundleId: 'com.np.hamrofutsal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCJNRKGJAAvEU30MNbwk6mgiSeRI_R6L-I',
    appId: '1:900384285987:ios:2fdce3bc99bb6488005896',
    messagingSenderId: '900384285987',
    projectId: 'hamro-futsal-6f95c',
    storageBucket: 'hamro-futsal-6f95c.firebasestorage.app',
    iosBundleId: 'com.np.hamrofutsal',
  );
}
