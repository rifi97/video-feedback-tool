//
//  FeedbackSidebarView.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

/// 피드백 사이드바 뷰
struct FeedbackSidebarView: View {
    @ObservedObject var feedbackViewModel: FeedbackViewModel
    @ObservedObject var videoViewModel: VideoPlayerViewModel
    var isInputFocused: FocusState<Bool>.Binding
    
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단: 제목 + 내보내기 버튼
            headerView
            
            Divider()
            
            // 중앙: 피드백 리스트
            feedbackListView
            
            Divider()
            
            // 하단: 입력 필드
            inputView
        }
        .frame(width: 300)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("피드백")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 전체 삭제 버튼
            if !feedbackViewModel.feedbackItems.isEmpty {
                Button(action: {
                    feedbackViewModel.clearAll()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("모든 피드백 삭제")
            }
            
            // 내보내기 버튼
            Button(action: {
                feedbackViewModel.exportToClipboard()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(feedbackViewModel.feedbackItems.isEmpty ? .gray : .accentColor)
            }
            .buttonStyle(.plain)
            .disabled(feedbackViewModel.feedbackItems.isEmpty)
            .help("노션 형식으로 클립보드에 복사")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Feedback List View
    private var feedbackListView: some View {
        Group {
            if feedbackViewModel.feedbackItems.isEmpty {
                // 빈 상태
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("피드백이 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("영상을 재생하면서 피드백을 입력하세요")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // 피드백 리스트
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(feedbackViewModel.feedbackItems) { item in
                                FeedbackItemView(
                                    item: item,
                                    onTap: {
                                        // 해당 타임스탬프로 이동
                                        videoViewModel.seek(to: item.timestamp)
                                    },
                                    onDelete: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            feedbackViewModel.deleteFeedback(item: item)
                                        }
                                    }
                                )
                                .id(item.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: feedbackViewModel.feedbackItems.count) { _, _ in
                        // 새 피드백 추가 시 스크롤
                        if let lastItem = feedbackViewModel.feedbackItems.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastItem.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Input View
    private var inputView: some View {
        FeedbackInputView(text: $inputText, isFocused: isInputFocused) {
            let currentTime = videoViewModel.getCurrentTime()
            feedbackViewModel.addFeedback(text: inputText, at: currentTime)
            inputText = ""
        }
        .padding(12)
    }
}

// Preview disabled - requires FocusState binding
