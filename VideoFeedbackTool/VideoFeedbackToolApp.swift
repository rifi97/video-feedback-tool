//
//  VideoFeedbackToolApp.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

@main
struct VideoFeedbackToolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 700)
        .commands {
            // 파일 메뉴 커스터마이징
            CommandGroup(replacing: .newItem) {}
        }
    }
}
