import UIKit
import Flutter
import home_widget
import workmanager

let flutterEngine = FlutterEngine(name: "SharedEngine", project: nil, allowHeadlessExecution: true)
let widgetGroupId = "group.com.zhushenwudi.lovelivemusicplayer"

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
            selector: #selector(handleNotification(_:)),
            name: Notification.Name("fromWigetToRunner"),
            object: nil
        )
    }
  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        flutterEngine.run()
        FlutterChannelManager.shared.initial()
        
        GeneratedPluginRegistrant.register(with: flutterEngine)
        UMConfigure.setLogEnabled(true)
        UMConfigure.initWithAppkey("634bdfd305844627b56670a1", channel: "Umeng")

        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60 * 5))

        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: flutterEngine)
        }

        if #available(iOS 17, *) {
            HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
                GeneratedPluginRegistrant.register(with: flutterEngine)
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
    }
    
    @objc func handleNotification(_ notification: Notification) {
        if let url = notification.userInfo?["url"] as? String {
            DispatchQueue.main.async {
                FlutterChannelManager.shared.homeWidgetChannel?.invokeMethod("host", arguments: ["url": url])
            }
        }
    }
}

class FlutterChannelManager {
    static let shared = FlutterChannelManager()
    var homeWidgetChannel: FlutterMethodChannel?
    var imageChannel: FlutterMethodChannel?
    
    private init() {}
    
    func initial() {
        homeWidgetChannel = FlutterMethodChannel(name: "home_widget", binaryMessenger: flutterEngine.binaryMessenger)
        imageChannel = FlutterMethodChannel(name: "refreshWidgetPhoto", binaryMessenger: flutterEngine.binaryMessenger)
        
        imageChannel?.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "shareImage" {
                if let args = call.arguments as? [String: Any],
                    let path = args["path"] as? String {
                        self?.saveImageToFile(imagePath: path)
                        result("Image shared successfully")
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                    }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    func saveImageToFile(imagePath: String) {
        guard let image = UIImage(contentsOfFile: imagePath) else { return }
        
        // 计算自适应的高度
        let targetSize = calculateAspectRatioSize(image: image, targetWidth: 100)
        
        // 缩放图像
        let resizedImage = resizeImage(image: image, targetSize: targetSize)
        
        let fileURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: widgetGroupId
        )?.appendingPathComponent("sharedImage.png")
        
        if let data = resizedImage.pngData() {
            do {
                try data.write(to: fileURL!)
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        // 提取图片主颜色
        if let color = image.dominantColor() {
            let userDefaults = UserDefaults(suiteName: widgetGroupId)
            userDefaults?.set("\(color.red),\(color.green),\(color.blue)", forKey: "bgColor")
            userDefaults?.synchronize()
        }
    }
    
    func calculateAspectRatioSize(image: UIImage, targetWidth: CGFloat) -> CGSize {
        let aspectRatio = image.size.height / image.size.width
        let targetHeight = targetWidth * aspectRatio
        return CGSize(width: targetWidth, height: targetHeight)
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension UIImage {
    func dominantColor() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 1
        let height = 1
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)))
        guard let data = context.data else { return nil }
        let pixel = data.bindMemory(to: UInt8.self, capacity: 3)
        return (red: CGFloat(pixel[0]), green: CGFloat(pixel[1]), blue: CGFloat(pixel[2]))
    }
}
