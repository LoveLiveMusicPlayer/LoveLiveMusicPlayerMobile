import UIKit
import AVKit
import SnapKit

class PipViewController: FlutterViewController, AVPictureInPictureControllerDelegate {
    // 承载PIP的播放器
    private var playerLayer: AVPlayerLayer!
    // PIP控制器
    var pipController: AVPictureInPictureController!
    // PIP中要渲染的View
    var customView: UIView!
    // 歌词控件
    var currentLyric: UITextView!
    var nextLyric: UITextView!
    
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
        let channel = FlutterMethodChannel(name: "pip", binaryMessenger: flutterEngine.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "start" {
                self?.startPip()
                result(true)
            } else if (call.method == "stop") {
                self?.stopPip()
                result(true)
            } else if (call.method == "update") {
                if let args = call.arguments as? [String: Any],
                   let currentLyric = args["current"] as? String,
                   let nextLyric = args["next"] as? String {
                    self?.updatePip(
                        currentLyric: currentLyric,
                        nextLyric: nextLyric
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

        // 创建 currentLyric
        currentLyric = UITextView()
        currentLyric.text = ""
        currentLyric.backgroundColor = .black
        currentLyric.textColor = .white
        currentLyric.font = UIFont.boldSystemFont(ofSize: 20)
        currentLyric.isUserInteractionEnabled = false
        currentLyric.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(currentLyric)

        // 创建 nextLyric
        nextLyric = UITextView()
        nextLyric.text = ""
        nextLyric.backgroundColor = .black
        nextLyric.textColor = .white
        nextLyric.font = UIFont.boldSystemFont(ofSize: 20)
        nextLyric.isUserInteractionEnabled = false
        nextLyric.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(nextLyric)

        // 设置 Auto Layout 约束
        NSLayoutConstraint.activate([
            // currentLyric 约束
            currentLyric.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            currentLyric.topAnchor.constraint(equalTo: customView.topAnchor, constant: 2),
            currentLyric.heightAnchor.constraint(equalToConstant: 55),
            currentLyric.widthAnchor.constraint(equalTo: customView.widthAnchor, multiplier: 0.95),

            // nextLyric 约束
            nextLyric.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            nextLyric.topAnchor.constraint(equalTo: currentLyric.bottomAnchor, constant: 2),
            nextLyric.heightAnchor.constraint(equalToConstant: 55), // 设置高度
            nextLyric.widthAnchor.constraint(equalTo: customView.widthAnchor, multiplier: 0.95)
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
    
    @objc private func updatePip(currentLyric: String, nextLyric: String) {
        self.currentLyric.text = currentLyric
        self.nextLyric.text = nextLyric
    }
}
