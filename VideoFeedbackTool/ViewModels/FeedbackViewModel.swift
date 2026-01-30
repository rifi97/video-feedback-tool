//
//  FeedbackViewModel.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import Foundation
import AVFoundation
import AppKit

/// 피드백 관리를 위한 ViewModel
class FeedbackViewModel: ObservableObject {
    @Published var feedbackItems: [FeedbackItem] = []
    @Published var showCopiedAlert: Bool = false
    
    /// 새 피드백 추가
    func addFeedback(text: String, at timestamp: TimeInterval) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newItem = FeedbackItem(timestamp: timestamp, text: text)
        feedbackItems.append(newItem)
    }
    
    /// 피드백 삭제
    func deleteFeedback(at offsets: IndexSet) {
        feedbackItems.remove(atOffsets: offsets)
    }
    
    /// 특정 피드백 삭제
    func deleteFeedback(item: FeedbackItem) {
        feedbackItems.removeAll { $0.id == item.id }
    }
    
    /// 모든 피드백 삭제
    func clearAll() {
        feedbackItems.removeAll()
    }
    
    /// 노션 형식으로 클립보드에 복사
    func exportToClipboard() {
        guard !feedbackItems.isEmpty else { return }
        
        // 타임스탬프 순으로 정렬
        let sortedItems = feedbackItems.sorted { $0.timestamp < $1.timestamp }
        
        // Notion To-do 형식으로 변환
        let notionText = sortedItems.map { $0.notionFormat }.joined(separator: "\n")
        
        // 클립보드에 복사
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(notionText, forType: .string)
        
        // 알림 표시
        showCopiedAlert = true
        
        // 2초 후 알림 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCopiedAlert = false
        }
    }
}
