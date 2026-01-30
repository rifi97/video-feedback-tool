//
//  FeedbackItem.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import Foundation

/// 피드백 항목을 나타내는 데이터 모델
struct FeedbackItem: Identifiable, Equatable {
    let id = UUID()
    let timestamp: TimeInterval // 영상의 초 단위 시간
    let text: String // 사용자가 적은 피드백
    
    /// 포맷팅 된 시간 문자열 반환 (예: "01:32")
    var formattedTime: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Notion To-do 형식으로 변환
    var notionFormat: String {
        return "- [ ] \(formattedTime) \(text)"
    }
}
