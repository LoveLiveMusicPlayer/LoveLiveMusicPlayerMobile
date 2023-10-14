@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        let controller = FlutterViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
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
}
