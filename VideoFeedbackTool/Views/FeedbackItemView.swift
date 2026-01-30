//
//  FeedbackItemView.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

/// 개별 피드백 항목 뷰
struct FeedbackItemView: View {
    let item: FeedbackItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 타임스탬프 배지
            Text(item.formattedTime)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                )
            
            // 피드백 텍스트
            Text(item.text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            // 삭제 버튼 (호버 시에만 표시)
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovering ? Color.secondary.opacity(0.15) : Color.secondary.opacity(0.1))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        FeedbackItemView(
            item: FeedbackItem(timestamp: 92, text: "오타가 있어요"),
            onTap: {},
            onDelete: {}
        )
        FeedbackItemView(
            item: FeedbackItem(timestamp: 135, text: "화면이 너무 어두움, 밝기 조절이 필요합니다"),
            onTap: {},
            onDelete: {}
        )
    }
    .padding()
    .frame(width: 300)
}
