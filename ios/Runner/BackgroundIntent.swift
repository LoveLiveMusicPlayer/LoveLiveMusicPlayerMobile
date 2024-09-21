//
//  BackgroundIntent.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/9/19.
//

import AppIntents
import Foundation
import home_widget

@available(iOS 17, *)
public struct BackgroundIntent: AppIntent {
  static public var title: LocalizedStringResource = "HomeWidget Background Intent"

  @Parameter(title: "Widget URI")
  var url: URL?

  @Parameter(title: "AppGroup")
  var appGroup: String?

  public init() {}
    
  public init(url: URL?) {
    self.url = url
  }

  public func perform() async throws -> some IntentResult {
      NotificationCenter.default.post(name: Notification.Name("fromWigetToRunner"), object: nil, userInfo: ["url": url!.absoluteString])
    return .result()
  }
}

/// This is required if you want to have the widget be interactive even when the app is fully suspended.
/// Note that this will launch your App so on the Flutter side you should check for the current Lifecycle State before doing heavy tasks
@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
extension BackgroundIntent: ForegroundContinuableIntent {}
