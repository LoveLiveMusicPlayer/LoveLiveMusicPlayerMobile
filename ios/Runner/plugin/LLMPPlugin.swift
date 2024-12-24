//
//  LLMPPlugin.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class LLMPPlugin: BasePlugin {
    override var pluginName: String {
        return "llmp"
    }
    
    override func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {}
    
    func handleSchemeRequest(url: String) {
        invokeMethod(method: "handleSchemeRequest", arguments: ["url": url])
    }
}
