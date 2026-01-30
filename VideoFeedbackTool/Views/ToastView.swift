//
//  ToastView.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI

/// 토스트 메시지 뷰
struct ToastView: View {
    let message: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.8))
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

/// 토스트 표시용 ViewModifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    ToastView(message: message, icon: icon)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowing)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, icon: String = "checkmark.circle.fill") -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message, icon: icon))
    }
}

#Preview {
    VStack {
        Text("Content")
    }
    .frame(width: 400, height: 300)
    .toast(isShowing: .constant(true), message: "복사되었습니다!")
}
