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
    
    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 비디오 플레이어
            VideoPlayerView(viewModel: videoViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    // 비디오 영역 클릭 시 텍스트 필드 포커스 해제
                    isInputFocused = false
                }
            
            Divider()
            
            // 오른쪽: 피드백 사이드바
            FeedbackSidebarView(
                feedbackViewModel: feedbackViewModel,
                videoViewModel: videoViewModel,
                isInputFocused: $isInputFocused
            )
        }
        .toast(
            isShowing: $feedbackViewModel.showCopiedAlert,
            message: "클립보드에 복사되었습니다!",
            icon: "checkmark.circle.fill"
        )
        .frame(minWidth: 900, minHeight: 600)
        // 키보드 단축키: 좌우 화살표로 프레임 이동
        .onKeyPress(.leftArrow) {
            videoViewModel.stepBackward()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            videoViewModel.stepForward()
            return .handled
        }
    }
}

#Preview {
    ContentView(feedbackViewModel: FeedbackViewModel())
}


