//
//  NotionFeedbackParser.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import Foundation

struct NotionFeedbackParser {
    private static let lineRegex = try? NSRegularExpression(
        pattern: #"^\s*(?:[-*]\s*)?(?:\[[ xX]\]\s*)?((?:\d+:)?\d+:\d{2})\s+(.+?)\s*$"#
    )
    
    static func parseItems(from text: String) -> [FeedbackItem] {
        text.components(separatedBy: .newlines).compactMap(parseLine)
    }
    
    static func parseLine(_ line: String) -> FeedbackItem? {
        let nsLine = line as NSString
        let range = NSRange(location: 0, length: nsLine.length)
        
        guard let lineRegex,
              let match = lineRegex.firstMatch(in: line, range: range),
              match.numberOfRanges == 3,
              let timestamp = parseTimestamp(nsLine.substring(with: match.range(at: 1))) else {
            return nil
        }
        
        let feedbackText = nsLine.substring(with: match.range(at: 2))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !feedbackText.isEmpty else { return nil }
        return FeedbackItem(timestamp: timestamp, text: feedbackText)
    }
    
    static func parseTimestamp(_ timestamp: String) -> TimeInterval? {
        let rawParts = timestamp.split(separator: ":", omittingEmptySubsequences: false)
        guard rawParts.count == 2 || rawParts.count == 3 else { return nil }
        guard rawParts.allSatisfy({ !$0.isEmpty }) else { return nil }
        
        let parts = rawParts.compactMap { Int($0) }
        guard parts.count == rawParts.count else { return nil }
        
        if parts.count == 2 {
            guard rawParts[1].count == 2 else { return nil }
            
            let minutes = parts[0]
            let seconds = parts[1]
            guard minutes >= 0, seconds >= 0, seconds < 60 else { return nil }
            return secondsToTimeInterval(minutes: minutes, seconds: seconds)
        }
        
        guard rawParts[1].count == 2, rawParts[2].count == 2 else { return nil }
        
        let hours = parts[0]
        let minutes = parts[1]
        let seconds = parts[2]
        
        guard hours >= 0, minutes >= 0, minutes < 60, seconds >= 0, seconds < 60 else { return nil }
        return secondsToTimeInterval(hours: hours, minutes: minutes, seconds: seconds)
    }
    
    private static func secondsToTimeInterval(hours: Int = 0, minutes: Int, seconds: Int) -> TimeInterval? {
        let (hourSeconds, hourOverflow) = hours.multipliedReportingOverflow(by: 3600)
        guard !hourOverflow else { return nil }
        
        let (minuteSeconds, minuteOverflow) = minutes.multipliedReportingOverflow(by: 60)
        guard !minuteOverflow else { return nil }
        
        let (subtotal, subtotalOverflow) = hourSeconds.addingReportingOverflow(minuteSeconds)
        guard !subtotalOverflow else { return nil }
        
        let (totalSeconds, totalOverflow) = subtotal.addingReportingOverflow(seconds)
        guard !totalOverflow else { return nil }
        guard totalSeconds <= FeedbackItem.maxSupportedTimestampSeconds else { return nil }
        
        return TimeInterval(totalSeconds)
    }
}
