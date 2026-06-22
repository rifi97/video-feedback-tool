//
//  FeedbackInputView.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

/// 피드백 입력 뷰
struct FeedbackInputView: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // 텍스트 입력 필드
            TextField("피드백을 입력하세요...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .lineLimit(1 ... 6)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.1))
                )
                .focused(isFocused)
                .onSubmit {
                    submitFeedback()
                }
            
            // 전송 버튼
            Button(action: submitFeedback) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(text.isEmpty ? Color.gray : Color.accentColor)
                    )
            }
            .buttonStyle(.plain)
            .disabled(text.isEmpty)
            .onHover { hovering in
                if hovering && !text.isEmpty {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
    
    private func submitFeedback() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSubmit()
    }
}

// Preview disabled - requires FocusState binding
