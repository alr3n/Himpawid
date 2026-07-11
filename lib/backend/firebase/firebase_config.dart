import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDZhzymbRrrMPwR4xfM_1RAFAPbAHhjGIQ",
            authDomain: "himpawid-z3so4d.firebaseapp.com",
            projectId: "himpawid-z3so4d",
            storageBucket: "himpawid-z3so4d.firebasestorage.app",
            messagingSenderId: "285739978637",
            appId: "1:285739978637:web:7af4e13f2f42869f0ff7c4",
            measurementId: "G-SVPS1HH6LQ"));
  } else {
    await Firebase.initializeApp();
  }
}
