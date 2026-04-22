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
  }) async {
    final doc = await _firestore
        .collection(FirebaseConstants.tripsCollection)
        .add({
      'riderId': riderId,
      'driverId': null,
      'status': 'requested',
      'pickup': pickup,
      'dropoff': dropoff,
      'fare': fare,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Rider listens for real-time changes on their trip document
  /// When driver accepts: driverId gets set and status changes to 'accepted'
  /// This stream omatically via Firefires autstore's onSnapshot
  Stream<DocumentSnapshot> watchTrip(String tripId) {
    return _firestore
        .collection(FirebaseConstants.tripsCollection)
        .doc(tripId)
        .snapshots();
  }

  /// Cancel a trip request
  Future<void> cancelTrip(String tripId) async {
    await _firestore
        .collection(FirebaseConstants.tripsCollection)
        .doc(tripId)
        .update({'status': 'cancelled'});
  }
}
