// File: lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';

import '../core/errors/exceptions.dart';
import '../firebase_options.dart';

/// Centralized Firebase service for app initialization and configuration
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase with proper error handling
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore settings
      await _configureFirestore();

      // Configure Auth settings
      await _configureAuth();

      _isInitialized = true;
    } catch (e) {
      throw DatabaseException('Failed to initialize Firebase: $e');
    }
  }

  /// Configure Firestore settings for optimal performance
  Future<void> _configureFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Enable offline persistence
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Enable network for real-time updates
      await firestore.enableNetwork();
    } catch (e) {
      // Non-critical error, log but don't throw
      print('Warning: Could not configure Firestore settings: $e');
    }
  }

  /// Configure Firebase Auth settings
  Future<void> _configureAuth() async {
    try {
      final auth = fb_auth.FirebaseAuth.instance;

      // Set language code
      await auth.setLanguageCode('en');

      // Configure auth settings if needed
      // auth.settings.forceRecaptchaFlowForTesting = false;
    } catch (e) {
      // Non-critical error, log but don't throw
      print('Warning: Could not configure Auth settings: $e');
    }
  }

  /// Get current Firebase user
  fb_auth.User? getCurrentUser() {
    return fb_auth.FirebaseAuth.instance.currentUser;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return getCurrentUser() != null;
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore {
    _ensureInitialized();
    return FirebaseFirestore.instance;
  }

  /// Get Auth instance
  fb_auth.FirebaseAuth get auth {
    _ensureInitialized();
    return fb_auth.FirebaseAuth.instance;
  }

  /// Ensure Firebase is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const DatabaseException('Firebase not initialized. Call initialize() first.');
    }
  }

  /// Sign out and clear any cached data
  Future<void> signOut() async {
    try {
      await auth.signOut();

      // Clear Firestore cache if needed
      await firestore.clearPersistence();
      await firestore.enableNetwork();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  /// Check Firebase connection status
  Future<bool> checkConnection() async {
    try {
      await firestore.doc('_connection_test/test').get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
