import UIKit
import AVKit

class MainViewController: FlutterViewController {
    private var pipManager = PipScreenManager()
    
    required init(coder: NSCoder) {
        FlutterChannelManager.shared.pipPlugin = PipPlugin(pipManager: pipManager)
        super.init(coder: coder)
    }

    override init(engine: FlutterEngine, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        FlutterChannelManager.shared.pipPlugin = PipPlugin(pipManager: pipManager)
        super.init(engine: engine, nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipManager.addScreenView(on: view)
            pipManager.picInPicAutoOpen(true)
            
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive),
               name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    // 当app回到前台时
    @objc func appDidBecomeActive() {
        // 关闭pip窗口
        pipManager.manualChangePicInPic(needStart: false)
        FlutterChannelManager.shared.pipPlugin?.getPlayerStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
