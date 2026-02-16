//
//  AudioPlayerManager.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import Foundation
import AVFoundation
import Combine

class AudioPlayerManager: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    func playSong(_ song: Song) {
        // Stop current playback
        stop()
        
        currentSong = song
        
        // In a real app, this would stream from YouTube Music
        // For now, we'll use a placeholder to demonstrate the functionality
        // You would need to integrate with YouTube Music API or use a third-party library
        
        // Example: Create a URL for the YouTube video (this won't work directly)
        // In production, you'd need to extract the audio stream URL
        let youtubeURL = "https://www.youtube.com/watch?v=\(song.youtubeId)"
        
        // For demonstration purposes, we'll simulate playback
        // In a real app, you'd use XCDYouTubeKit or similar library
        simulatePlayback(for: song)
    }
    
    private func simulatePlayback(for song: Song) {
        // This is a simulation. In a real app, you would:
        // 1. Use YouTube Music API to get the stream URL
        // 2. Create AVPlayer with that URL
        // 3. Seek to startTime
        // 4. Set up observer to stop at endTime (if specified)
        
        isPlaying = true
        duration = song.duration
        currentTime = song.startTime
        
        // Simulate time updates
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                
                self.currentTime += 1
                
                // Check if we should stop at endTime
                if let endTime = song.endTime, self.currentTime >= endTime {
                    self.stop()
                } else if self.currentTime >= song.duration {
                    self.stop()
                }
            }
            .store(in: &cancellables)
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else if currentSong != nil {
            resume()
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        cancellables.removeAll()
    }
    
    func skipForward() {
        guard let player = player else { return }
        let newTime = player.currentTime() + CMTime(seconds: 10, preferredTimescale: 1)
        player.seek(to: newTime)
    }
    
    func skipBackward() {
        guard let player = player else { return }
        let newTime = player.currentTime() - CMTime(seconds: 10, preferredTimescale: 1)
        player.seek(to: newTime)
    }
    
    func seekToTime(_ time: TimeInterval) {
        guard let player = player else { return }
        let cmTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: cmTime)
        currentTime = time
    }
}
