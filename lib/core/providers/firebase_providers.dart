// lib/core/providers/firebase_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/feature/auth/service/authentication_service.dart';

// Provedor para a instância do FirebaseAuth
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Provedor para a instância do FirebaseFirestore
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Provedor para a instância do FirebaseAnalytics
final firebaseAnalyticsProvider =
    Provider<FirebaseAnalytics>((ref) => FirebaseAnalytics.instance);

// Provider para Realtime Database
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

// Provedor para a instância do GoogleSignIn
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

// Provedor para o AuthenticationService
// Ele usa os provedores acima para injetar as dependências no AuthenticationService
final authServiceProvider = Provider<AuthenticationService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final analytics = ref.watch(firebaseAnalyticsProvider);
  // Não passamos googleSignIn aqui, pois AuthenticationService já o inicializa internamente.
  // Se você quisesse injetá-lo, passaria ref.watch(googleSignInProvider) aqui.
  return AuthenticationService(auth, firestore, analytics);
});
