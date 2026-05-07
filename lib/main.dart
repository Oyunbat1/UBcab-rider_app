import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/app/routes/app_pages.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/core/services/audio_service.dart';
import 'package:rider_app/features/auth/logic/auth_api.dart';
import 'package:rider_app/features/auth/logic/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthApi(), permanent: true);
  Get.put(AuthController(authApi: Get.find<AuthApi>()), permanent: true);
  Get.put(AudioService(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ridenow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
