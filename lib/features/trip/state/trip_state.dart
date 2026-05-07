import 'package:get/get.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';

class TripState {
  final tripStatus = Rx<TripStatus?>(null);
  final activeTrip = Rx<Map<String, dynamic>?>(null);
  final activeTripId = Rx<String?>(null);
  final fareEstimate = 0.obs;
  final isRequesting = false.obs;

  final acceptedAt = Rx<DateTime?>(null);
  final elapsed = '00:00'.obs;

  final driverName = ''.obs;
  final driverPhone = ''.obs;
  final driverVehicle = ''.obs;
  final driverPlate = ''.obs;
  final driverRating = 0.0.obs;
}
