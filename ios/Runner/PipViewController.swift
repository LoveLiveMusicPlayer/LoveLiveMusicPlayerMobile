import UIKit
import AVKit
import SnapKit

class PipViewController: FlutterViewController, AVPictureInPictureControllerDelegate {
    // 承载PIP的播放器
    private var playerLayer: AVPlayerLayer!
    // PIP控制器
    private var pipController: AVPictureInPictureController!
    // PIP中要渲染的View
    private var customView: UIView!
    // 歌词控件
    private var lyricLine1: UITextView!
    private var lyricLine2: UITextView!
    private var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AVPictureInPictureController.isPictureInPictureSupported() {
            initMethodChannel()
            setupPlayer()
            setupPip()
            setupCustomView()
        }
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
                    let lyricLine1 = args["lyricLine1"] as? String
                    let lyricLine2 = args["lyricLine2"] as? String
                    let currentLine = args["currentLine"] as? Int

                    self?.updatePip(
                        lyricLine1: lyricLine1,
                        lyricLine2: lyricLine2,
                        currentLine: currentLine!
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
    
    // 画中画将要弹出
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // 注意是 first window
        if let window = UIApplication.shared.windows.first {
            // 把自定义view加到画中画上
            window.addSubview(customView)
            // 使用自动布局
            customView.snp.makeConstraints { (make) -> Void in
                make.edges.equalToSuperview()
            }
        }
    }
    
    // 配置播放器
    private func setupPlayer() {
        playerLayer = AVPlayerLayer()
        playerLayer.frame = .init(x: -1, y: -1, width: 0.1, height: 0.1)
        playerLayer.videoGravity = .resizeAspect
        let video = Bundle.main.url(forResource: "black", withExtension: "mp4")
        let playerItem = AVPlayerItem.init(asset: AVAsset.init(url: video!))
        playerLayer.player = AVPlayer.init(playerItem: playerItem)
        playerLayer.player?.isMuted = true
        playerLayer.player?.allowsExternalPlayback = true
        view.layer.addSublayer(playerLayer)
        playerLayer.player?.play()
    }
    
    // 配置画中画
    private func setupPip() {
        pipController = AVPictureInPictureController.init(playerLayer: playerLayer)!
        pipController.delegate = self
        // 隐藏播放按钮、快进快退按钮
        pipController.setValue(1, forKey: "controlsStyle")
        // 进入后台自动开启画中画（必须处于播放状态）
        if #available(iOS 14.2, *) {
            pipController.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }
    
    // 配置自定义view
    private func setupCustomView() {
        // 创建 customView
        customView = UIView()
        customView.backgroundColor = .black
        customView.translatesAutoresizingMaskIntoConstraints = false

        // 创建 lyricLine1
        lyricLine1 = UITextView()
        lyricLine1.text = ""
        lyricLine1.backgroundColor = .black
        lyricLine1.textColor = .white
        lyricLine1.font = UIFont.boldSystemFont(ofSize: 20)
        lyricLine1.isUserInteractionEnabled = false
        lyricLine1.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(lyricLine1)

        // 创建 lyricLine2
        lyricLine2 = UITextView()
        lyricLine2.text = ""
        lyricLine2.backgroundColor = .black
        lyricLine2.textColor = .white
        lyricLine2.font = UIFont.boldSystemFont(ofSize: 20)
        lyricLine2.isUserInteractionEnabled = false
        lyricLine2.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(lyricLine2)
        
        // 创建 appIcon
        icon = UIImageView(image: UIImage(named: "AppIcon"))
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(icon)

        // 设置 Auto Layout 约束
        NSLayoutConstraint.activate([
            // lyricLine1 约束
            lyricLine1.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            lyricLine1.topAnchor.constraint(equalTo: customView.topAnchor, constant: 2),
            lyricLine1.heightAnchor.constraint(equalToConstant: 55),
            lyricLine1.widthAnchor.constraint(equalTo: customView.widthAnchor, multiplier: 0.95),

            // lyricLine2 约束
            lyricLine2.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            lyricLine2.topAnchor.constraint(equalTo: lyricLine1.bottomAnchor, constant: 2),
            lyricLine2.heightAnchor.constraint(equalToConstant: 55), // 设置高度
            lyricLine2.widthAnchor.constraint(equalTo: customView.widthAnchor, multiplier: 0.95),
            
            // appIcon 约束
            icon.bottomAnchor.constraint(equalTo: customView.bottomAnchor, constant: -10),
            icon.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -10),
            icon.widthAnchor.constraint(equalToConstant: 30),
            icon.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func startPip() {
        print("start pip...")
        self.pipController.startPictureInPicture()
    }
    
    @objc private func stopPip() {
        print("stop pip...")
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        }
    }
    
    @objc private func updatePip(
        lyricLine1: String?,
        lyricLine2: String?,
        currentLine: Int
    ) {
        if lyricLine1 != nil {
            self.lyricLine1.text = lyricLine1
        }
        if lyricLine2 != nil {
            self.lyricLine2.text = lyricLine2
        }
        self.lyricLine1.textColor = currentLine == 2 ? UIColor.lightGray : UIColor.white
        self.lyricLine2.textColor = currentLine == 1 ? UIColor.lightGray : UIColor.white
    }
}
