import UIKit
import AVKit

class PipViewController: FlutterViewController {
    private var manager = PicInPicScreenManager()
    private var channel: FlutterMethodChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AVPictureInPictureController.isPictureInPictureSupported() {
            manager.addScreenView(on: view)
            manager.picInPicAutoOpen(true)
            initMethodChannel()
            
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive),
               name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appDidBecomeActive() {
        // 当 app 回到前台时关闭 pip 窗口
        manager.manalChangePicInPic(needStart: false)
        // 获取播放器的播放状态
        channel?.invokeMethod("isPlaying", arguments: nil) { (result) in
            if let isPlaying = result as? Bool {
                if (isPlaying) {
                    // 如果播放器处于播放状态，需要主动调用一下
                    // 防止后续没有播放状态回调导致再次切换到后台时（处于播放状态）无法自动弹出 pip 窗口
                    self.manager.picInPicAutoOpen(nil)
                }
            }
        }
    }
    
    private func initMethodChannel() {
        channel = FlutterMethodChannel(name: "desktop_lyric", binaryMessenger: flutterEngine.binaryMessenger)
        channel?.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "pipAutoOpen" {
                if let autoOpen = call.arguments as? Bool {
                    self?.pipAutoOpen(autoOpen: autoOpen)
                }
                result(true)
            } else if (call.method == "update") {
                if let args = call.arguments as? [String: Any] {
                    self?.updatePip(
                        lyricLine1: args["lyricLine1"] as? String,
                        lyricLine2: args["lyricLine2"] as? String,
                        currentLine: (args["currentLine"] as? Int)!
                    )
                    result(true)
                } else {
                    result(false)
                }
            } else if (call.method == "isPlaying") {
                // 接收播放状态回调
                if let isPlaying = call.arguments as? Bool {
                    if isPlaying {
                        // 如果处于播放状态，只调用pipController.player.play()
                        // 只有player处于play状态，切到后台才会自动弹出pip窗口
                        self?.manager.picInPicAutoOpen(nil)
                    } else {
                        // 如果处于暂停状态，调用pipController.player.pause()、pipController.stopPictureInPicture()
                        // 当player处于pause状态，切到后台才不会自动弹出pip窗口
                        self?.manager.manalChangePicInPic(needStart: false)
                    }
                }
                result(true)
            } else {
                result(false)
            }
        }
    }
    
    // 根据应用设置是否开启桌面歌词来决定是否允许切换到后台时自动弹出 pip 窗口
    @objc private func pipAutoOpen(autoOpen: Bool) {
        manager.picInPicAutoOpen(autoOpen)
    }
    
    @objc private func updatePip(lyricLine1: String?, lyricLine2: String?, currentLine: Int) {
        manager.updatePipScreenView(lyricLine1: lyricLine1, lyricLine2: lyricLine2, currentLine: currentLine)
    }
}
