import UIKit
import AVKit

class PipViewController: FlutterViewController {
    private var manager = PicInPicScreenManager()
    
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
        manager.manalChangePicInPic(needStart: false)
    }
    
    private func initMethodChannel() {
        let channel = FlutterMethodChannel(name: "desktop_lyric", binaryMessenger: flutterEngine.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "start" {
                self?.startPip()
                result(true)
            } else if (call.method == "stop") {
                self?.stopPip()
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
            } else {
                result(false)
            }
        }
    }
    
    @objc private func startPip() {
        manager.picInPicAutoOpen(true)
    }
    
    @objc private func stopPip() {
        manager.picInPicAutoOpen(false)
    }
    
    @objc private func updatePip(lyricLine1: String?, lyricLine2: String?, currentLine: Int) {
        manager.updatePipScreenView(lyricLine1: lyricLine1, lyricLine2: lyricLine2, currentLine: currentLine)
    }
}
