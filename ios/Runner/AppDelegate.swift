import UIKit
import Flutter
import home_widget
import workmanager

var flutterEngine: FlutterEngine?
let widgetGroupId = "group.com.zhushenwudi.lovelivemusicplayer"

public var sharedFlutterEngine: FlutterEngine {
    if flutterEngine == nil {
        flutterEngine = FlutterEngine(name: "SharedEngine", project: nil, allowHeadlessExecution: true)
    }
    return flutterEngine!
}

public var binaryMessenger: FlutterBinaryMessenger {
    return sharedFlutterEngine.binaryMessenger
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override init() {
        super.init()
        // 监听APP终止
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        // 监听从Home Widget传来的点击事件
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleClickEventNotification(_:)),
            name: Notification.Name("fromWigetToRunner"),
            object: nil
        )
    }
  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        sharedFlutterEngine.run()
        FlutterChannelManager.shared.initialize()
        
        GeneratedPluginRegistrant.register(with: sharedFlutterEngine)
        UMConfigure.setLogEnabled(true)
        UMConfigure.initWithAppkey("634bdfd305844627b56670a1", channel: "Umeng")

        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60 * 5))

        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: sharedFlutterEngine)
        }

        if #available(iOS 17, *) {
            HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
                GeneratedPluginRegistrant.register(with: sharedFlutterEngine)
            }
        }
        
        let userDefaults = UserDefaults(suiteName: widgetGroupId)
        userDefaults?.set(false, forKey: "isShutdown")
        
        return true
    }
    
    @objc func appWillTerminate() {
        let userDefaults = UserDefaults(suiteName: widgetGroupId)
        userDefaults?.set(false, forKey: "isPlaying")
        userDefaults?.set("", forKey: "curJpLrc")
        userDefaults?.set("", forKey: "nextJpLrc")
        userDefaults?.set(true, forKey: "isShutdown")
        flutterEngine = nil
    }
    
    @objc func handleClickEventNotification(_ notification: Notification) {
        if let url = notification.userInfo?["url"] as? String {
            FlutterChannelManager.shared.homeWidgetPlugin?.postClickEvent(url: url)
        }
    }
}
