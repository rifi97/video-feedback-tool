//
//  VideoPlayerViewModel.swift
//  VideoFeedbackTool
//
//  Created for Video Feedback Tool
//

import Foundation
import AVFoundation
import AVKit
import Combine

/// 비디오 플레이어 관리를 위한 ViewModel
class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isVideoLoaded: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupTimeObserver()
    }
    
    deinit {
        removeTimeObserver()
    }
    
    /// 비디오 파일 로드
    func loadVideo(url: URL) {
        // 기존 플레이어 정리
        removeTimeObserver()
        
        // 새 플레이어 생성
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // 비디오 길이 가져오기
        Task {
            if let duration = try? await playerItem.asset.load(.duration) {
                await MainActor.run {
                    self.duration = CMTimeGetSeconds(duration)
                }
            }
        }
        
        isVideoLoaded = true
        setupTimeObserver()
        
        // 재생 상태 관찰
        player?.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isPlaying = status == .playing
            }
            .store(in: &cancellables)
    }
    
    /// 시간 관찰자 설정
    private func setupTimeObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
        }
    }
    
    /// 시간 관찰자 제거
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    /// 특정 시간으로 이동
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 재생/일시정지 토글
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
    }
    
    /// 현재 재생 시간 반환
    func getCurrentTime() -> TimeInterval {
        guard let player = player else { return 0 }
        return CMTimeGetSeconds(player.currentTime())
    }
}
