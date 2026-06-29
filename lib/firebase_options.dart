// File ini di-generate berdasarkan google-services.json project CampuShare.
// Project ID : campushare-668d9
// Package    : com.example.campushare

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'CampuShare belum dikonfigurasi untuk Web. '
        'Tambahkan konfigurasi web di Firebase Console jika diperlukan.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'CampuShare belum dikonfigurasi untuk iOS. '
          'Tambahkan GoogleService-Info.plist jika diperlukan.',
        );
      default:
        throw UnsupportedError(
          'Platform tidak didukung: $defaultTargetPlatform',
        );
    }
  }

  // ─── Konfigurasi Android (dari google-services.json) ─────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9elPeGhiIbfeCCBwKJoyvPVVGV-v1918',
    appId: '1:82470000555:android:5e69e09919fb8ed9d924ee',
    messagingSenderId: '82470000555',
    projectId: 'campushare-668d9',
    storageBucket: 'campushare-668d9.firebasestorage.app',
  );
}
