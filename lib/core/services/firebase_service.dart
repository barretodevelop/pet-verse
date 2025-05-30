import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String petsCollection = 'pets';
  static const String adoptionRequestsCollection = 'adoption_requests';

  // Auth helpers
  static String? get currentUserId => _auth.currentUser?.uid;
  static bool get isAuthenticated => _auth.currentUser != null;

  // Collection references
  static CollectionReference get users =>
      _firestore.collection(usersCollection);
  static CollectionReference get pets => _firestore.collection(petsCollection);
  static CollectionReference get adoptionRequests =>
      _firestore.collection(adoptionRequestsCollection);

  // Batch operations
  static WriteBatch batch() => _firestore.batch();

  // Transaction helper
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) =>
      _firestore.runTransaction(updateFunction);
}
