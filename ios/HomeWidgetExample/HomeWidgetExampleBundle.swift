//
//  HomeWidgetExampleBundle.swift
//  HomeWidgetExample
//
//  Created by hoshizora-rin on 2024/9/19.
//

import WidgetKit
import SwiftUI

@main
struct HomeWidgetExampleBundle: WidgetBundle {
    var body: some Widget {
        HomeWidgetExampleWhite()
        HomeWidgetExampleBlack()
        if #available(iOS 18.0, *) {
            HomeWidgetExampleControl()
        }
        HomeWidgetExampleLiveActivity()
    }
}
