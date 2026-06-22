//
//  FeedbackItem.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import Foundation

/// 피드백 항목을 나타내는 데이터 모델
struct FeedbackItem: Identifiable, Equatable {
    static let maxSupportedTimestampSeconds = 1_000_000_000_000
    
    let id = UUID()
    let timestamp: TimeInterval // 영상의 초 단위 시간
    let text: String // 사용자가 적은 피드백
    
    /// 포맷팅 된 시간 문자열 반환 (예: "01:32")
    var formattedTime: String {
        guard timestamp.isFinite,
              timestamp >= 0,
              timestamp <= TimeInterval(Self.maxSupportedTimestampSeconds) else {
            return "00:00"
        }
        
        let totalSeconds = Int(timestamp)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Notion To-do 형식으로 변환
    var notionFormat: String {
        return "- [ ] \(formattedTime) \(text)"
    }
}
