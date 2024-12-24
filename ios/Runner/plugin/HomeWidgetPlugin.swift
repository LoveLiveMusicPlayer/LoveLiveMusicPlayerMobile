//
//  HomeWidgetPlugin.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class HomeWidgetPlugin: BasePlugin {
    override var pluginName: String {
        return "home_widget"
    }
    
    override func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {}
    
    func postClickEvent(url: String) {
        invokeMethod(method: "event", arguments: ["url": url])
    }
}
