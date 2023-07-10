import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UMConfigure.setLogEnabled(true)
    UMConfigure.initWithAppkey("634bdfd305844627b56670a1", channel:"Umeng")
    if #available(iOS 12.0, *) {
        return true;
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
