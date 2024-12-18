import umeng_push_sdk
import UMPush

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        UNUserNotificationCenter.current().delegate = self

        let controller = PipViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        controller.loadDefaultSplashScreenView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 冷启动处理Scheme请求
            if let urlContext = connectionOptions.urlContexts.first {
                self.handleSchemeRequest(urlContext.url)
            }
        }
    }
    
    // 运行时处理Scheme请求
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            handleSchemeRequest(urlContext.url)
        }
    }
    
    func handleSchemeRequest(_ url: URL) {
        let channel = FlutterMethodChannel(name: "llmp", binaryMessenger: flutterEngine.binaryMessenger)
        channel.invokeMethod("handleSchemeRequest", arguments: ["url": url.absoluteString])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        UmengPushSdkPlugin.didReceiveUMessage(userInfo)
        print("-----------willPresentNotification")
        
        if notification.request.trigger is UNPushNotificationTrigger {
            UMessage.setAutoAlert(false)
            // 应用处于前台时的远程推送接受
            // 必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        } else {
            // 应用处于前台时的本地推送接受
        }
        
        // 控制推送消息是否直接在前台显示
        completionHandler([.sound, .badge, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("-----------didReceiveNotificationResponse")
        UmengPushSdkPlugin.didOpenUMessage(userInfo)
        
        if response.notification.request.trigger is UNPushNotificationTrigger {
            // 应用处于后台时的远程推送接受
            // 必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        } else {
            // 应用处于后台时的本地推送接受
        }
        
        completionHandler()
    }
}
