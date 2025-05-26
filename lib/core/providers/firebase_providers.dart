// lib/core/providers/firebase_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Provider para FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider para Firestore
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider para Realtime Database
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

// Provider para Google Sign In
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});