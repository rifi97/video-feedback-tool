//
//  ContentView.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

/// 메인 콘텐츠 뷰
struct ContentView: View {
    @StateObject private var videoViewModel = VideoPlayerViewModel()
    @ObservedObject var feedbackViewModel: FeedbackViewModel
    @FocusState private var isInputFocused: Bool
    @State private var videoFocusRequest: Int = 0
    
    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 비디오 플레이어
            VideoPlayerView(viewModel: videoViewModel, focusRequest: videoFocusRequest)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    // 비디오 영역 클릭 시 텍스트 필드 포커스 해제
                    focusVideoPlayer()
                }
            
            Divider()
            
            // 오른쪽: 피드백 사이드바
            FeedbackSidebarView(
                feedbackViewModel: feedbackViewModel,
                videoViewModel: videoViewModel,
                isInputFocused: $isInputFocused,
                onVideoFocusRequested: focusVideoPlayer
            )
        }
        .toast(
            isShowing: $feedbackViewModel.showCopiedAlert,
            message: feedbackViewModel.toastMessage,
            icon: feedbackViewModel.toastIcon
        )
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private func focusVideoPlayer() {
        isInputFocused = false
        videoFocusRequest += 1
    }
}

#Preview {
    ContentView(feedbackViewModel: FeedbackViewModel())
}
