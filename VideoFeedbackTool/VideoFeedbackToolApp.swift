//
//  VideoFeedbackToolApp.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

@main
struct VideoFeedbackToolApp: App {
    @StateObject private var feedbackViewModel = FeedbackViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(feedbackViewModel: feedbackViewModel)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 700)
        .commands {
            // 파일 메뉴 커스터마이징
            CommandGroup(replacing: .newItem) {}
            
            // 편집 메뉴에 내보내기 추가
            CommandGroup(after: .pasteboard) {
                Button("피드백을 클립보드로 내보내기") {
                    feedbackViewModel.exportToClipboard()
                }
                .keyboardShortcut("e", modifiers: .command)
            }
        }
    }
}

