//
//  YouTubeMusicImportView.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI
import CoreData

struct YouTubeMusicImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var youtubeService = YouTubeMusicService()

    @State private var urlsInput: String = ""
    @State private var isImporting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var importedSongs: [Song] = []

    private var parsedURLs: [String] {
        urlsInput
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                        .padding(.top, 24)

                    Text("Import Songs")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Paste one or more YouTube Music / YouTube URLs. Songs will be imported into storage with thumbnails, details, and ready-to-preview playback.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        TextEditor(text: $urlsInput)
                            .frame(minHeight: 120)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )

                        HStack {
                            Text("Detected URLs: \(parsedURLs.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        Button(action: importSongs) {
                            HStack {
                                if isImporting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 5)
                                }
                                Text(isImporting ? "Importing..." : "Import URLs")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(parsedURLs.isEmpty || isImporting ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(parsedURLs.isEmpty || isImporting)

                        if !importedSongs.isEmpty {
                            Button(action: saveImportedSongs) {
                                Text("Save \(importedSongs.count) Songs to Library")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if !importedSongs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Imported Song Preview")
                                .font(.headline)

                            LazyVStack(spacing: 10) {
                                ForEach(importedSongs) { song in
                                    ImportedSongPreviewRow(song: song)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Import Songs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func importSongs() {
        isImporting = true

        Task {
            do {
                let songs = try await youtubeService.importSongs(urls: parsedURLs)

                await MainActor.run {
                    importedSongs = songs
                    isImporting = false
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

    private func saveImportedSongs() {
        let fetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SongEntity.order, ascending: false)]
        fetchRequest.fetchLimit = 1

        var nextOrder: Int = 0
        if let lastSong = try? viewContext.fetch(fetchRequest).first {
            nextOrder = Int(lastSong.order) + 1
        }

        for (index, song) in importedSongs.enumerated() {
            let newSong = SongEntity(context: viewContext)
            var songWithOrder = song
            songWithOrder.order = nextOrder + index
            songWithOrder.startTime = 0
            songWithOrder.endTime = nil
            songWithOrder.update(entity: newSong)
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            errorMessage = "Error saving songs: \(nsError.localizedDescription)"
            showError = true
        }
    }
}

struct ImportedSongPreviewRow: View {
    let song: Song
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: song.thumbnailURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.secondary)
                    )
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Duration: \(formatTime(song.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                audioPlayerManager.playSong(song)
            }) {
                Image(systemName: audioPlayerManager.isPlaying && audioPlayerManager.currentSong?.id == song.id ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct YouTubeMusicImportView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeMusicImportView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AudioPlayerManager())
    }
}
