//
//  PipPlugin.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class BasePlugin {
    var channel: FlutterMethodChannel?
    var pluginName: String {
        fatalError("Subclasses must override pluginName")
    }
    
    init() {
        initMethodChannel()
    }
    
    func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {}
    
    private func initMethodChannel() {
        channel = FlutterMethodChannel(name: pluginName, binaryMessenger: binaryMessenger)
        channel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call: call, result: result)
        }
    }
    
    func invokeMethodWithResult<T>(method: String, arguments: Any?, completion: @escaping (T?) -> Void) {
        channel?.invokeMethod(method, arguments: arguments) { (result) in
            completion(result as? T)
        }
    }
    
    func invokeMethod(method: String, arguments: Any?) {
        channel?.invokeMethod(method, arguments: arguments)
    }
}
