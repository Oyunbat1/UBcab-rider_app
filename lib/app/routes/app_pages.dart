import 'package:get/get.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/features/auth/logic/auth_binding.dart';
import 'package:rider_app/features/auth/view/splash_view.dart';
import 'package:rider_app/features/auth/view/login_view.dart';
import 'package:rider_app/features/auth/view/otp_view.dart';
import 'package:rider_app/features/trip/logic/trip_binding.dart';
import 'package:rider_app/features/trip/view/map_view.dart';
import 'package:rider_app/features/trip/view/trip_active_view.dart';
import 'package:rider_app/features/profile/logic/profile_binding.dart';
import 'package:rider_app/features/profile/view/profile_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MapView(),
      binding: TripBinding(),
    ),
    GetPage(
      name: AppRoutes.tripActive,
      page: () => const TripActiveView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
