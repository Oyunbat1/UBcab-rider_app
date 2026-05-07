import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_app/core/constants/firebase_constants.dart';

class TripApi {
  final _firestore = FirebaseFirestore.instance;

  /// Rider - iin ilgeej bui new trip request
  /// status:'requested' and driverId:null , firestore-luu shine doc bichih
  /// Driver app deeres snapshot-r damjuulan ywuulsan status:'requested' and driverId:null harah
  Future<String> createTrip({
    required String riderId,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required int fare,
    String? pickupAddress,
    String? dropoffAddress,
  }) async {
    final doc = await _firestore
        .collection(FirebaseConstants.tripsCollection)
        .add({
      'riderId': riderId,
      'driverId': null,
      'status': 'requested',
      'pickup': pickup,
      'dropoff': dropoff,
      'pickupAddress': pickupAddress ?? '',
      'dropoffAddress': dropoffAddress ?? '',
      'fare': fare,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Rider trip document real time sonson driver accept hiih vuy accepted bolj uurchlugduh heseg

  Stream<DocumentSnapshot> watchTrip(String tripId) {
    return _firestore
        .collection(FirebaseConstants.tripsCollection)
        .doc(tripId)
        .snapshots();
  }

  /// User doc-iig 1 udaa unshich driver-iin medeelliig avah heseg.
  Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    return doc.data();
  }

  /// Trip request tsutslah heseg
  Future<void> cancelTrip(String tripId) async {
    await _firestore
        .collection(FirebaseConstants.tripsCollection)
        .doc(tripId)
        .update({'status': 'cancelled'});
  }
}
