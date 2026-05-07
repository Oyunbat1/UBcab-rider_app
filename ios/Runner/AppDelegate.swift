  import Flutter
  import UIKit
  import GoogleMaps

  @main
  @objc class AppDelegate: FlutterAppDelegate {
    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions:
  [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      GMSServices.provideAPIKey("AIzaSyDgfMVv_Qv9c6tdCwrSS_oQLVCN2L8gdnY")
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions:
  launchOptions)
    }
  }
