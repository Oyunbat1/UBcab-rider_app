export 'package:rider_app/features/trip/logic/trip_controller.dart';
export 'package:rider_app/features/trip/logic/trip_api.dart';
export 'package:rider_app/features/trip/logic/trip_binding.dart';
export 'package:rider_app/features/trip/state/trip_state.dart';

enum TripStatus {
  requested,
  accepted,
  arriving,
  inProgress,
  completed,
  cancelled,
}
