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
    @Published var toastMessage: String = "클립보드에 복사되었습니다!"
    @Published var toastIcon: String = "checkmark.circle.fill"
    
    private var hideToastWorkItem: DispatchWorkItem?
    
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
        let notionHTML = buildNotionTodoHTML(from: sortedItems)
        
        // Notion은 HTML 체크리스트를 우선 해석하고, 일반 텍스트는 다른 앱/재가져오기용 백업으로 둔다.
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(notionHTML, forType: .html)
        pasteboard.setString(notionText, forType: .string)
        
        showToast(message: "클립보드에 복사되었습니다!", icon: "checkmark.circle.fill")
    }
    
    /// 클립보드의 노션 To-do 형식 피드백을 가져오기
    func importFromClipboard() {
        guard let clipboardText = NSPasteboard.general.string(forType: .string) else {
            showToast(message: "클립보드에 텍스트가 없습니다", icon: "exclamationmark.triangle.fill")
            return
        }
        
        let importedItems = NotionFeedbackParser.parseItems(from: clipboardText)
        guard !importedItems.isEmpty else {
            showToast(message: "가져올 피드백을 찾지 못했습니다", icon: "exclamationmark.triangle.fill")
            return
        }
        
        feedbackItems.append(contentsOf: importedItems)
        feedbackItems.sort { $0.timestamp < $1.timestamp }
        
        showToast(message: "\(importedItems.count)개 피드백을 불러왔습니다", icon: "square.and.arrow.down.fill")
    }

    private func buildNotionTodoHTML(from items: [FeedbackItem]) -> String {
        let listItems = items.map { item in
            let text = htmlEscaped("\(item.formattedTime) \(item.text)")
            return """
            <li class="task-list-item" data-checked="false"><input class="task-list-item-checkbox" type="checkbox" disabled="disabled"> \(text)</li>
            """
        }.joined(separator: "\n")
        
        return """
        <!doctype html>
        <html>
        <head><meta charset="utf-8"></head>
        <body>
        <ul class="contains-task-list">
        \(listItems)
        </ul>
        </body>
        </html>
        """
    }
    
    private func htmlEscaped(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    
    private func showToast(message: String, icon: String) {
        hideToastWorkItem?.cancel()
        toastMessage = message
        toastIcon = icon
        showCopiedAlert = true
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.showCopiedAlert = false
        }
        
        hideToastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}
