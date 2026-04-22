import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rider_app/features/profile/state/profile_state.dart';
import 'package:rider_app/features/profile/logic/profile_api.dart';

class ProfileController extends GetxController {
  final ProfileApi profileApi;
  final state = ProfileState();

  ProfileController({required this.profileApi});

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = await profileApi.getUserProfile(uid);
    if (data != null) {
      state.name.value = data['name'] ?? '';
      state.phone.value = data['phone'] ?? '';
      state.rating.value = (data['rating'] ?? 0).toDouble();
      state.totalTrips.value = data['totalTrips'] ?? 0;
      state.totalSpent.value = data['totalSpent'] ?? 0;
    }
  }
}
