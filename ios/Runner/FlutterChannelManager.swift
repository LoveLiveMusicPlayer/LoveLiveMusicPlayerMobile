//
//  FlutterChannelManager.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class FlutterChannelManager {
    static let shared = FlutterChannelManager()
    
    var homeWidgetPlugin: HomeWidgetPlugin?
    var imagePlugin: ImagePlugin?
    var llmpPlugin: LLMPPlugin?
    var pipPlugin: PipPlugin?
    
    private init() {}
    
    func initialize() {
        homeWidgetPlugin = HomeWidgetPlugin()
        imagePlugin = ImagePlugin()
    }
    
    func initLLMPPlugin() {
        if llmpPlugin == nil {
            llmpPlugin = LLMPPlugin()
        }
    }
}
