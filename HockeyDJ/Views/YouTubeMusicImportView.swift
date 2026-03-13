//
//  YouTubeMusicImportView.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI
import CoreData
import AVFoundation
import UniformTypeIdentifiers

struct YouTubeMusicImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var youtubeService = YouTubeMusicService()

    @State private var playlistURL: String = ""
    @State private var isImporting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var startMinutes: Int = 0
    @State private var startSeconds: Int = 0
    @State private var hasClipLength: Bool = false
    @State private var clipMinutes: Int = 0
    @State private var clipSeconds: Int = 30

    @State private var showFileImporter: Bool = false
    @State private var localFileURL: URL?
    @State private var localTitle: String = ""
    @State private var localArtist: String = ""
    @State private var localDuration: TimeInterval = 0
    @State private var localStartMinutes: Int = 0
    @State private var localStartSeconds: Int = 0
    @State private var hasLocalEndTime: Bool = false
    @State private var localEndMinutes: Int = 0
    @State private var localEndSeconds: Int = 0
    @State private var isPreviewingLocalSong: Bool = false

    @State private var previewPlayer: AVAudioPlayer?
    @State private var previewTimer: Timer?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    youtubeImportSection
                    Divider().padding(.vertical)
                    localImportSection
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Import Songs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopPreview()
                        dismiss()
                    }
                }
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav],
                allowsMultipleSelection: false
            ) { result in
                handleLocalFileSelection(result)
            }
            .onDisappear {
                stopPreview()
            }
        }
    }

    private var youtubeImportSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "music.note.list")
                .font(.system(size: 56))
                .foregroundColor(.red)
                .padding(.top, 30)

            Text("Import from YouTube Music")
                .font(.title3)
                .fontWeight(.bold)

            Text("Enter a YouTube Music playlist URL or video URL to import songs")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Playlist or Video URL", text: $playlistURL)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.URL)

            HStack {
                Picker("Start Minutes", selection: $startMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                .pickerStyle(.menu)

                Picker("Start Seconds", selection: $startSeconds) {
                    ForEach(0..<60) { second in
                        Text("\(second)s").tag(second)
                    }
                }
                .pickerStyle(.menu)
            }

            Toggle("Limit song length", isOn: $hasClipLength)

            if hasClipLength {
                HStack {
                    Picker("Clip Minutes", selection: $clipMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)m").tag(minute)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Clip Seconds", selection: $clipSeconds) {
                        ForEach(0..<60) { second in
                            Text("\(second)s").tag(second)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Button(action: importPlaylist) {
                HStack {
                    if isImporting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    Text(isImporting ? "Importing..." : "Import from YouTube")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(playlistURL.isEmpty || isImporting ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(playlistURL.isEmpty || isImporting)
        }
        .padding(.horizontal)
    }

    private var localImportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import a Local Song")
                .font(.title3)
                .fontWeight(.bold)

            Text("Choose an audio file, preview it, and set where playback starts and stops.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Choose Audio File") {
                showFileImporter = true
            }
            .buttonStyle(.borderedProminent)

            if let localFileURL {
                Text("Selected: \(localFileURL.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            TextField("Song Title", text: $localTitle)
                .textFieldStyle(.roundedBorder)

            TextField("Artist", text: $localArtist)
                .textFieldStyle(.roundedBorder)

            HStack {
                Picker("Start Minutes", selection: $localStartMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                .pickerStyle(.menu)

                Picker("Start Seconds", selection: $localStartSeconds) {
                    ForEach(0..<60) { second in
                        Text("\(second)s").tag(second)
                    }
                }
                .pickerStyle(.menu)
            }

            Toggle("Set end time", isOn: $hasLocalEndTime)

            if hasLocalEndTime {
                HStack {
                    Picker("End Minutes", selection: $localEndMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)m").tag(minute)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("End Seconds", selection: $localEndSeconds) {
                        ForEach(0..<60) { second in
                            Text("\(second)s").tag(second)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Text("Duration: \(formatDuration(localDuration))")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Button(isPreviewingLocalSong ? "Stop Preview" : "Preview Clip") {
                    if isPreviewingLocalSong {
                        stopPreview()
                    } else {
                        previewLocalSong()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(localFileURL == nil)

                Button("Import Local Song") {
                    saveLocalSong()
                }
                .buttonStyle(.borderedProminent)
                .disabled(localFileURL == nil || localTitle.isEmpty)
            }
        }
        .padding(.horizontal)
    }

    private func importPlaylist() {
        isImporting = true

        Task {
            do {
                let songs = try await youtubeService.importPlaylist(url: playlistURL)

                await MainActor.run {
                    saveSongs(songs)
                    isImporting = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isImporting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func saveSongs(_ songs: [Song]) {
        let fetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SongEntity.order, ascending: false)]
        fetchRequest.fetchLimit = 1

        var nextOrder: Int = 0
        if let lastSong = try? viewContext.fetch(fetchRequest).first {
            nextOrder = Int(lastSong.order) + 1
        }

        for (index, song) in songs.enumerated() {
            let newSong = SongEntity(context: viewContext)
            var songWithOrder = song
            songWithOrder.order = nextOrder + index
            songWithOrder.startTime = TimeInterval(startMinutes * 60 + startSeconds)

            if hasClipLength {
                let clipLength = TimeInterval(clipMinutes * 60 + clipSeconds)
                if clipLength > 0 {
                    let targetEndTime = songWithOrder.startTime + clipLength
                    songWithOrder.endTime = min(targetEndTime, songWithOrder.duration)
                } else {
                    songWithOrder.endTime = nil
                }
            } else {
                songWithOrder.endTime = nil
            }

            songWithOrder.update(entity: newSong)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving songs: \(nsError), \(nsError.userInfo)")
        }
    }

    private func handleLocalFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let selectedURL = urls.first else { return }
            localFileURL = selectedURL
            if localTitle.isEmpty {
                localTitle = selectedURL.deletingPathExtension().lastPathComponent
            }
            loadLocalDuration(from: selectedURL)
        case .failure(let error):
            errorMessage = "Failed to select file: \(error.localizedDescription)"
            showError = true
        }
    }

    private func loadLocalDuration(from url: URL) {
        let asset = AVURLAsset(url: url)
        localDuration = CMTimeGetSeconds(asset.duration)
        if localDuration.isNaN || localDuration.isInfinite {
            localDuration = 0
        }

        let durationInt = max(0, Int(localDuration))
        localEndMinutes = min(durationInt / 60, 59)
        localEndSeconds = min(durationInt % 60, 59)
    }

    private func previewLocalSong() {
        guard let url = localFileURL else { return }

        do {
            stopPreview()
            let player = try AVAudioPlayer(contentsOf: url)
            previewPlayer = player

            let startTime = TimeInterval(localStartMinutes * 60 + localStartSeconds)
            let configuredEndTime = TimeInterval(localEndMinutes * 60 + localEndSeconds)
            let endTime = hasLocalEndTime && configuredEndTime > startTime ? min(configuredEndTime, player.duration) : player.duration

            player.currentTime = min(startTime, player.duration)
            player.prepareToPlay()
            player.play()
            isPreviewingLocalSong = true

            previewTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                guard let activePlayer = previewPlayer else { return }
                if !activePlayer.isPlaying || activePlayer.currentTime >= endTime {
                    stopPreview()
                }
            }
        } catch {
            errorMessage = "Preview failed: \(error.localizedDescription)"
            showError = true
        }
    }

    private func stopPreview() {
        previewPlayer?.stop()
        previewTimer?.invalidate()
        previewTimer = nil
        isPreviewingLocalSong = false
    }

    private func saveLocalSong() {
        guard let sourceURL = localFileURL else { return }

        do {
            let persistedPath = try copyImportedFileToAppStorage(from: sourceURL)

            let fetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SongEntity.order, ascending: false)]
            fetchRequest.fetchLimit = 1

            var nextOrder: Int = 0
            if let lastSong = try? viewContext.fetch(fetchRequest).first {
                nextOrder = Int(lastSong.order) + 1
            }

            let newSong = SongEntity(context: viewContext)
            let startTime = TimeInterval(localStartMinutes * 60 + localStartSeconds)
            let configuredEndTime = TimeInterval(localEndMinutes * 60 + localEndSeconds)
            let normalizedEndTime: TimeInterval? = hasLocalEndTime && configuredEndTime > startTime ? min(configuredEndTime, localDuration) : nil

            let song = Song(
                title: localTitle,
                artist: localArtist.isEmpty ? "Unknown Artist" : localArtist,
                youtubeId: "",
                audioFileURL: persistedPath,
                duration: localDuration,
                startTime: startTime,
                endTime: normalizedEndTime,
                order: nextOrder
            )

            song.update(entity: newSong)

            try viewContext.save()
            stopPreview()
            dismiss()
        } catch {
            errorMessage = "Failed to import local song: \(error.localizedDescription)"
            showError = true
        }
    }

    private func copyImportedFileToAppStorage(from sourceURL: URL) throws -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let audioDirectory = documentsDirectory.appendingPathComponent("ImportedAudio", isDirectory: true)

        try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)

        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        let fileExtension = sourceURL.pathExtension
        var destinationURL = audioDirectory.appendingPathComponent("\(baseName).\(fileExtension)")
        var counter = 1

        while FileManager.default.fileExists(atPath: destinationURL.path) {
            destinationURL = audioDirectory.appendingPathComponent("\(baseName)-\(counter).\(fileExtension)")
            counter += 1
        }

        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL.path
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration))
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

struct YouTubeMusicImportView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeMusicImportView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
