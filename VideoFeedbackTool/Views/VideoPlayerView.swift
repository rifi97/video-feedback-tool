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
    override var acceptsFirstResponder: Bool { true }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        window?.makeFirstResponder(self)
    }
    
    override func keyDown(with event: NSEvent) {
        if shouldHandlePlaybackShortcut(event),
           handlePlaybackKey(event) {
            return
        }
        
        super.keyDown(with: event)
    }
    
    func focusForPlayback() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.window?.makeFirstResponder(self)
        }
    }

    private func shouldHandlePlaybackShortcut(_ event: NSEvent) -> Bool {
        let reservedModifiers: NSEvent.ModifierFlags = [.command, .option, .control]
        guard event.modifierFlags.intersection(reservedModifiers).isEmpty else {
            return false
        }
        
        return [49, 123, 124].contains(event.keyCode)
    }

    private func handlePlaybackKey(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 49: // 스페이스바
            guard let player = self.player else { return false }
            
            if player.timeControlStatus == .playing {
                player.pause()
            } else {
                player.play()
            }
            focusForPlayback()
            return true
        case 123: // 왼쪽 화살표
            stepFrame(by: -frameStepCount(for: event))
            focusForPlayback()
            return true
        case 124: // 오른쪽 화살표
            stepFrame(by: frameStepCount(for: event))
            focusForPlayback()
            return true
        default:
            return false
        }
    }
    
    private func frameStepCount(for event: NSEvent) -> Int {
        event.modifierFlags.contains(.shift) ? 10 : 1
    }
    
    private func stepFrame(by count: Int) {
        guard let player, let currentItem = player.currentItem else { return }
        player.pause()
        currentItem.step(byCount: count)
    }
}

/// AVPlayerView 래퍼 (호버 시 어두워지는 효과 없음)
struct NativeVideoPlayerView: NSViewRepresentable {
    let player: AVPlayer
    let focusRequest: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> FocusableAVPlayerView {
        let playerView = FocusableAVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .floating
        playerView.showsFullScreenToggleButton = true
        context.coordinator.lastFocusRequest = focusRequest
        return playerView
    }
    
    func updateNSView(_ nsView: FocusableAVPlayerView, context: Context) {
        nsView.player = player
        
        if context.coordinator.lastFocusRequest != focusRequest {
            context.coordinator.lastFocusRequest = focusRequest
            nsView.focusForPlayback()
        }
    }
    
    class Coordinator {
        var lastFocusRequest: Int?
    }
}

/// 비디오 플레이어 뷰
struct VideoPlayerView: View {
    @ObservedObject var viewModel: VideoPlayerViewModel
    let focusRequest: Int
    @State private var isHovering: Bool = false
    @State private var isDragOver: Bool = false
    
    init(viewModel: VideoPlayerViewModel, focusRequest: Int = 0) {
        self.viewModel = viewModel
        self.focusRequest = focusRequest
    }
    
    var body: some View {
        ZStack {
            // 배경
            Color.black
            
            if viewModel.isVideoLoaded, let player = viewModel.player {
                // 비디오 플레이어 (호버 시 어두워지지 않음)
                NativeVideoPlayerView(player: player, focusRequest: focusRequest)
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
