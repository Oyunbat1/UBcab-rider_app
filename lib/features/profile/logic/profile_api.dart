import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_app/core/constants/firebase_constants.dart';

class ProfileApi {
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    return doc.data();
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update(data);
  }
}
