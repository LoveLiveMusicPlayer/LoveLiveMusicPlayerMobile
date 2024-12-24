//
//  PipPlugin.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class PipPlugin: BasePlugin {
    var pipManager: PipScreenManager

    override var pluginName: String {
        return "desktop_lyric"
    }
    
    init(pipManager: PipScreenManager) {
        self.pipManager = pipManager
        super.init()
    }
    
    override func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "pipAutoOpen" {
            if let autoOpen = call.arguments as? Bool {
                pipAutoOpen(autoOpen: autoOpen)
            }
            result(true)
        } else if (call.method == "update") {
            if let args = call.arguments as? [String: Any] {
                updatePip(
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
                    pipAutoOpen(autoOpen: nil)
                } else {
                    // 如果处于暂停状态，调用pipController.player.pause()、pipController.stopPictureInPicture()
                    // 当player处于pause状态，切到后台才不会自动弹出pip窗口
                    manualChangePicInPic(needStart: false)
                }
            }
            result(true)
        } else {
            result(false)
        }
    }
    
    // 获取播放器的播放状态
    public func getPlayerStatus() {
        invokeMethodWithResult(method: "isPlaying", arguments: nil) { (result: Bool?) in
            if let isPlaying = result {
                if (isPlaying) {
                    // 如果播放器处于播放状态，需要主动调用一下
                    // 防止后续没有播放状态回调导致再次切换到后台时（处于播放状态）无法自动弹出 pip 窗口
                    self.pipAutoOpen(autoOpen: nil)
                }
            }
        }
    }
    
    // 根据应用设置是否开启桌面歌词来决定是否允许切换到后台时自动弹出 pip 窗口
    private func pipAutoOpen(autoOpen: Bool?) {
        DispatchQueue.main.async {
            self.pipManager.picInPicAutoOpen(autoOpen)
        }
    }
    
    private func updatePip(lyricLine1: String?, lyricLine2: String?, currentLine: Int) {
        DispatchQueue.main.async {
            self.pipManager.updatePipScreenView(
                lyricLine1: lyricLine1,
                lyricLine2: lyricLine2,
                currentLine: currentLine
            )
        }
    }
    
    private func manualChangePicInPic(needStart: Bool) {
        DispatchQueue.main.async {
            self.pipManager.manualChangePicInPic(needStart: needStart)
        }
    }
}
