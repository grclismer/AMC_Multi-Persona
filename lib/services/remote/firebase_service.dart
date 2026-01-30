import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:amc_persona/model/chat_session.dart';

class FirebaseService {
  // Methods for Auth and Firestore will go here

  // 🛡️ Extra Safe Gate: Check if Firebase is actually configured
  bool get _isReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestore =>
      _isReady ? FirebaseFirestore.instance : null;
  FirebaseAuth? get _auth => _isReady ? FirebaseAuth.instance : null;

  // matches "Firebase Authentication" in diagram
  User? get currentUser => _auth?.currentUser;

  // matches "Cloud Firestore (NoSQL DB)" and "Background Synchronization" in diagram
  Future<void> syncSessionToCloud(ChatSession session) async {
    if (!_isReady) return; // Keep it silent, don't crash

    final store = _firestore;
    final auth = _auth;
    final user = auth?.currentUser;

    if (store == null || user == null) return;

    try {
      await store
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(session.id)
          .set(session.toMap());
    } on FirebaseException catch (e) {
      print("Firebase Sync Error: ${e.message}");
    } catch (e) {
      print("General Sync Error: $e");
    }
  }

  // Placeholder for auth methods
  Future<void> signInAnonymously() async {
    if (!_isReady) return;
    try {
      await _auth?.signInAnonymously();
    } on FirebaseException catch (e) {
      print("Firebase Auth Error: ${e.message}");
    }
  }
}
