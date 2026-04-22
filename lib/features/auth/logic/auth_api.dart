import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_app/core/constants/firebase_constants.dart';

class AuthApi {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Oruulsan dugaarluu opt ywuulah heseg;
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
  /// Irsen code oo verify hiih heseg;
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Firestore deer hereglegchiin medeelel hadgalah heseg
  Future<void> saveUserDoc({
    required String uid,
    required String phone,
  }) async {
    final docRef = _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'phone': phone,
        'role': 'rider',
        'name': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
