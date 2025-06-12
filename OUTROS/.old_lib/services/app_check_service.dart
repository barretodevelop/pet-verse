// File: lib/services/app_check_service.dart
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:firebase_core/firebase_core.dart';

// class AppCheckService {
//   static Future<void> initialize() async {
//     try {
//       await FirebaseAppCheck.instance.activate(
//         // Android
//         androidProvider: AndroidProvider.debug, // ou .playIntegrity
//         // iOS
//         appleProvider: AppleProvider.debug, // ou .deviceCheck/.appAttest
//       );

//       print('✅ Firebase App Check initialized');
//     } catch (e) {
//       print('❌ App Check initialization failed: $e');
//     }
//   }

//   static Future<String?> getToken({bool forceRefresh = false}) async {
//     try {
//       final token = await FirebaseAppCheck.instance.getToken(forceRefresh);
//       print('🔐 AppCheck Token: ${token?.token}');
//       return token?.token;
//     } catch (e) {
//       print('❌ Failed to get App Check token: $e');
//       return null;
//     }
//   }
// }
