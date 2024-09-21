//
//  HomeWidgetExampleLiveActivity.swift
//  HomeWidgetExample
//
//  Created by hoshizora-rin on 2024/9/19.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HomeWidgetExampleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HomeWidgetExampleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HomeWidgetExampleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HomeWidgetExampleAttributes {
    fileprivate static var preview: HomeWidgetExampleAttributes {
        HomeWidgetExampleAttributes(name: "World")
    }
}

extension HomeWidgetExampleAttributes.ContentState {
    fileprivate static var smiley: HomeWidgetExampleAttributes.ContentState {
        HomeWidgetExampleAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HomeWidgetExampleAttributes.ContentState {
         HomeWidgetExampleAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HomeWidgetExampleAttributes.preview) {
   HomeWidgetExampleLiveActivity()
} contentStates: {
    HomeWidgetExampleAttributes.ContentState.smiley
    HomeWidgetExampleAttributes.ContentState.starEyes
}
