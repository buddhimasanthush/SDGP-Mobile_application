import UIKit
import Flutter
import GoogleMaps   // ← Step 1: This import is added for Google Maps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Step 2: PASTE YOUR GOOGLE MAPS API KEY BELOW
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    // ✅ REPLACE "YOUR_API_KEY_HERE" WITH YOUR ACTUAL KEY

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}