//
//  VideoPlayerView.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import SwiftUI
import AVKit
import UniformTypeIdentifiers

/// 클릭 시 포커스를 받는 커스텀 AVPlayerView
class FocusableAVPlayerView: AVPlayerView {
    private var trackingArea: NSTrackingArea?
    
    override var acceptsFirstResponder: Bool { true }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // 뷰가 윈도우에 추가되면 즉시 포커스 획득
        DispatchQueue.main.async { [weak self] in
            self?.window?.makeFirstResponder(self)
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        // 기존 tracking area 제거
        if let existingArea = trackingArea {
            removeTrackingArea(existingArea)
        }
        
        // 새 tracking area 추가 (마우스 진입 감지)
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        // 마우스가 영역에 들어오면 포커스 획득
        window?.makeFirstResponder(self)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        window?.makeFirstResponder(self)
    }
    
    override func keyDown(with event: NSEvent) {
        // 스페이스바 (키코드 49)
        if event.keyCode == 49 {
            if let player = self.player {
                if player.timeControlStatus == .playing {
                    player.pause()
                } else {
                    player.play()
                }
            }
        } else {
            super.keyDown(with: event)
        }
    }
}

/// AVPlayerView 래퍼 (호버 시 어두워지는 효과 없음)
struct NativeVideoPlayerView: NSViewRepresentable {
    let player: AVPlayer
    
    func makeNSView(context: Context) -> FocusableAVPlayerView {
        let playerView = FocusableAVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .floating
        playerView.showsFullScreenToggleButton = true
        return playerView
    }
    
    func updateNSView(_ nsView: FocusableAVPlayerView, context: Context) {
        nsView.player = player
    }
}

/// 비디오 플레이어 뷰
struct VideoPlayerView: View {
    @ObservedObject var viewModel: VideoPlayerViewModel
    @State private var isHovering: Bool = false
    @State private var isDragOver: Bool = false
    
    var body: some View {
        ZStack {
            // 배경
            Color.black
            
            if viewModel.isVideoLoaded, let player = viewModel.player {
                // 비디오 플레이어 (호버 시 어두워지지 않음)
                NativeVideoPlayerView(player: player)
            } else {
                // 파일 열기 버튼
                VStack(spacing: 20) {
                    Image(systemName: "film")
                        .font(.system(size: 60))
                        .foregroundColor(isDragOver ? .accentColor : .gray)
                    
                    Button(action: openFile) {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("파일 열기")
                        }
                        .font(.title2)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor)
                        )
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        isHovering = hovering
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    
                    Text(isDragOver ? "파일을 놓으세요" : "MP4, MOV, M4V 파일을 지원합니다\n또는 여기에 파일을 드래그하세요")
                        .font(.caption)
                        .foregroundColor(isDragOver ? .accentColor : .gray)
                        .multilineTextAlignment(.center)
                }
            }
            
            // 드래그 오버 시 테두리
            if isDragOver {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 3)
                    .padding(8)
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
            handleDrop(providers: providers)
        }
    }
    
    /// 드래그 앤 드롭 처리
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard error == nil,
                  let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            // 지원하는 비디오 형식인지 확인
            let supportedExtensions = ["mp4", "mov", "m4v"]
            if supportedExtensions.contains(url.pathExtension.lowercased()) {
                DispatchQueue.main.async {
                    viewModel.loadVideo(url: url)
                }
            }
        }
        
        return true
    }
    
    /// 파일 열기 다이얼로그
    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie, .mpeg4Movie, .quickTimeMovie]
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.loadVideo(url: url)
        }
    }
}

#Preview {
    VideoPlayerView(viewModel: VideoPlayerViewModel())
}
