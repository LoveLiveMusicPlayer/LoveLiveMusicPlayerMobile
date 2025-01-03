import AVKit
import UIKit
import SnapKit

@MainActor
class PipScreenManager: NSObject, @preconcurrency AVPictureInPictureControllerDelegate {

    private var firstWindow: UIWindow?
    private var pipController: AVPictureInPictureController?
    
    // 控制器中显示的
    private var screenView: PipScreenView = PipScreenView()
    // 画中画中显示的
    private var picInPicView: PipScreenView = PipScreenView()
    private var isOpenPicInPic = true
    // 疑似画中画的window
    private var suspectedWindows: [UIWindow] = []

    override init() {
        super.init()
        isOpenPicInPic = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func addScreenView(on view: UIView) {
        view.addSubview(screenView)
        screenView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-30)
            make.bottom.equalTo(view).offset(50)
            make.height.equalTo(50)
        }
        view.layoutIfNeeded()
        preparePicInPic(on: screenView)
    }

    
    func removeScreenView() {
        screenView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
        suspectedWindows.removeAll()
    }

    private func preparePicInPic(on view: UIView) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }

        let url = Bundle.main.url(forResource: "black", withExtension: "mp4")!
        let item = AVPlayerItem(asset: AVAsset(url: url))
        let player = AVPlayer(playerItem: item)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = .init(x: 0, y: 0, width: 0.1, height: 0.1)
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspectFill

        view.layer.insertSublayer(playerLayer, at: 0)

        // 画中画功能
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        if #available(iOS 14.0, *) {
            pipController?.requiresLinearPlayback = true
        }
        pipController?.setValue(1, forKey: "controlsStyle")
        pipController?.delegate = self
        if #available(iOS 14.2, *) {
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisible), name: UIWindow.didBecomeVisibleNotification, object: nil)
    }

    func picInPicAutoOpen(_ isOpen: Bool?) {
        if isOpen != nil {
            isOpenPicInPic = isOpen!
        }
        let isPlayingNow = pipController?.playerLayer.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing
        if isOpenPicInPic {
            if !isPlayingNow {
                pipController?.playerLayer.player?.play()
            }
        } else if isPlayingNow {
            pipController?.playerLayer.player?.pause()
        }
    }
    
    @objc func updatePipScreenView(lyricLine1: String?, lyricLine2: String?, currentLine: Int) {
        self.screenView.updateContent(lyricLine1: lyricLine1, lyricLine2: lyricLine2, currentLine: currentLine)
        self.picInPicView.updateContent(lyricLine1: lyricLine1, lyricLine2: lyricLine2, currentLine: currentLine)
    }

    @objc private func windowDidBecomeVisible(notification: Notification) {
        guard let object = notification.object else { return }
        if String(describing: type(of: object)) == "PGHostedWindow" {
            firstWindow = notification.object as? UIWindow
            NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeVisibleNotification, object: nil)
        } else if let targetWindow = object as? UIWindow {
            suspectedWindows.append(targetWindow)
        }
    }
    
    private func filterTargetWindow() -> UIWindow? {
        for window in suspectedWindows {
            if String(describing: type(of: window)) == "PGHostedWindow" {
                return window
            }
        }
        for window in suspectedWindows {
            if window.windowLevel == UIWindow.Level(rawValue: -10000000) {
                return window
            }
        }
        for window in suspectedWindows {
            if window.frame.size.height < 300 {
                return window
            }
        }
        return suspectedWindows.first
    }

    func changePicFrame() {
        let url = Bundle.main.url(forResource: "black", withExtension: "mp4")!
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        pipController?.playerLayer.player?.replaceCurrentItem(with: item)
    }

    @objc private func playerItemDidReachEnd(notification: Notification) {
        pipController?.playerLayer.player?.seek(to: .zero)
        pipController?.playerLayer.player?.play()
    }

    func manualChangePicInPic(needStart: Bool) {
        if needStart {
            pipController?.playerLayer.player?.play()
            if pipController?.isPictureInPictureActive == false {
                pipController?.startPictureInPicture()
            }
        }
        if !needStart {
            if pipController?.isPictureInPictureActive == true {
                pipController?.stopPictureInPicture()
            }
            pipController?.playerLayer.player?.pause()
        }
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if firstWindow == nil {
            firstWindow = filterTargetWindow()
            suspectedWindows.removeAll()
        }
        if let firstWindow = firstWindow {
            firstWindow.addSubview(picInPicView)
            picInPicView.snp.remakeConstraints { make in
                make.edges.equalTo(firstWindow)
            }
        }
        
        // 当 pip 窗口显示的时候调用一下启动动画，防止在 pip 界面没有发生布局大小改变的时候动画停止
        picInPicView.gradientLayer.animateGradient()
    }
}
