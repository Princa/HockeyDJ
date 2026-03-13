//
//  SongDetailView.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI
import CoreData
import AVFoundation

struct SongDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var song: SongEntity

    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var startMinutes: Int = 0
    @State private var startSeconds: Int = 0
    @State private var endMinutes: Int = 0
    @State private var endSeconds: Int = 0
    @State private var hasEndTime: Bool = false
    @State private var isPreviewing: Bool = false

    @State private var previewPlayer: AVAudioPlayer?
    @State private var previewTimer: Timer?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Song Information")) {
                    TextField("Title", text: $title)
                    TextField("Artist", text: $artist)
                }

                Section(header: Text("Start Time")) {
                    HStack {
                        Picker("Minutes", selection: $startMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Seconds", selection: $startSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)s").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 120)
                }

                Section(header: Text("End Time (Optional)")) {
                    Toggle("Set End Time", isOn: $hasEndTime)

                    if hasEndTime {
                        HStack {
                            Picker("Minutes", selection: $endMinutes) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)m").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)

                            Picker("Seconds", selection: $endSeconds) {
                                ForEach(0..<60) { second in
                                    Text("\(second)s").tag(second)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(height: 120)
                    }
                }

                if canPreviewLocalSong {
                    Section(header: Text("Preview")) {
                        Button(isPreviewing ? "Stop Preview" : "Preview Clip") {
                            if isPreviewing {
                                stopPreview()
                            } else {
                                previewClip()
                            }
                        }
                    }
                }

                Section(header: Text("Duration")) {
                    Text(formatDuration(song.duration))
                }

                Section(header: Text("YouTube Video ID")) {
                    Text(song.youtubeId ?? "N/A")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopPreview()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSong()
                        stopPreview()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSongData()
            }
            .onDisappear {
                stopPreview()
            }
        }
    }

    private var canPreviewLocalSong: Bool {
        guard let audioFileURL = song.audioFileURL else { return false }
        return FileManager.default.fileExists(atPath: audioFileURL)
    }

    private func loadSongData() {
        title = song.title ?? ""
        artist = song.artist ?? ""

        let startTime = Int(song.startTime)
        startMinutes = startTime / 60
        startSeconds = startTime % 60

        if song.endTime > 0 {
            hasEndTime = true
            let endTime = Int(song.endTime)
            endMinutes = endTime / 60
            endSeconds = endTime % 60
        }
    }

    private func saveSong() {
        song.title = title
        song.artist = artist
        song.startTime = TimeInterval(startMinutes * 60 + startSeconds)

        if hasEndTime {
            song.endTime = TimeInterval(endMinutes * 60 + endSeconds)
        } else {
            song.endTime = 0
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving song: \(nsError), \(nsError.userInfo)")
        }
    }

    private func previewClip() {
        guard let audioPath = song.audioFileURL else { return }

        do {
            stopPreview()
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            previewPlayer = player

            let startTime = TimeInterval(startMinutes * 60 + startSeconds)
            let configuredEndTime = TimeInterval(endMinutes * 60 + endSeconds)
            let endTime = hasEndTime && configuredEndTime > startTime ? min(configuredEndTime, player.duration) : player.duration

            player.currentTime = min(startTime, player.duration)
            player.prepareToPlay()
            player.play()
            isPreviewing = true

            previewTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                guard let activePlayer = previewPlayer else { return }
                if !activePlayer.isPlaying || activePlayer.currentTime >= endTime {
                    stopPreview()
                }
            }
        } catch {
            print("Preview failed: \(error.localizedDescription)")
        }
    }

    private func stopPreview() {
        previewPlayer?.stop()
        previewTimer?.invalidate()
        previewTimer = nil
        isPreviewing = false
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
