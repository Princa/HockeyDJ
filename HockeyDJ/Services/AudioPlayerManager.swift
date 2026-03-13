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
    private var clipEndTime: TimeInterval?
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
        stop()
        currentSong = song

        if let audioFileURL = song.audioFileURL,
           !audioFileURL.isEmpty,
           FileManager.default.fileExists(atPath: audioFileURL) {
            playLocalSong(song, fileURL: URL(fileURLWithPath: audioFileURL))
        } else {
            simulatePlayback(for: song)
        }
    }

    private func playLocalSong(_ song: Song, fileURL: URL) {
        let item = AVPlayerItem(url: fileURL)
        player = AVPlayer(playerItem: item)
        duration = song.duration
        currentTime = song.startTime
        clipEndTime = song.endTime

        addTimeObserver()

        let startCMTime = CMTime(seconds: max(0, song.startTime), preferredTimescale: 600)
        player?.seek(to: startCMTime) { [weak self] _ in
            self?.player?.play()
            self?.isPlaying = true
        }
    }

    private func addTimeObserver() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let seconds = CMTimeGetSeconds(time)
            if seconds.isFinite {
                self.currentTime = seconds
            }

            if let end = self.clipEndTime, seconds >= end {
                self.stop()
            }
        }
    }

    private func simulatePlayback(for song: Song) {
        isPlaying = true
        duration = song.duration
        currentTime = song.startTime
        clipEndTime = song.endTime

        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }

                self.currentTime += 1

                if let endTime = self.clipEndTime, self.currentTime >= endTime {
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
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        player = nil
        clipEndTime = nil
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
