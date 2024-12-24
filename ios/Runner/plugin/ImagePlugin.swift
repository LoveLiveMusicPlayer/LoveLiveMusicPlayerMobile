//
//  ImagePlugin.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class ImagePlugin: BasePlugin {
    override var pluginName: String {
        return "refreshWidgetPhoto"
    }
    
    override func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "shareImage" {
            if let args = call.arguments as? [String: Any],
                let path = args["path"] as? String {
                    AppUtils.shared.saveImageToFile(imagePath: path)
                    result("Image shared successfully")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
