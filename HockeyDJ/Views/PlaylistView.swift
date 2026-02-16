//
//  PlaylistView.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI
import CoreData

struct PlaylistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SongEntity.order, ascending: true)],
        animation: .default)
    private var songs: FetchedResults<SongEntity>
    
    @State private var showingSongDetail = false
    @State private var selectedSong: SongEntity?
    
    var body: some View {
        VStack {
            if songs.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("No Songs Yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Import songs from YouTube Music to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(songs) { song in
                        SongRowView(song: song)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSong = song
                                showingSongDetail = true
                            }
                    }
                    .onDelete(perform: deleteSongs)
                    .onMove(perform: moveSongs)
                }
                .listStyle(.insetGrouped)
                
                // Player Controls
                if let currentSong = audioPlayerManager.currentSong {
                    PlayerControlsView(song: currentSong)
                        .padding()
                        .background(Color(.systemBackground))
                        .shadow(radius: 5)
                }
            }
        }
        .sheet(item: $selectedSong) { song in
            SongDetailView(song: song)
        }
    }
    
    private func deleteSongs(offsets: IndexSet) {
        withAnimation {
            offsets.map { songs[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting songs: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        var songsArray = Array(songs)
        songsArray.move(fromOffsets: source, toOffset: destination)
        
        for (index, song) in songsArray.enumerated() {
            song.order = Int16(index)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error moving songs: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct SongRowView: View {
    @ObservedObject var song: SongEntity
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title ?? "Unknown Title")
                    .font(.headline)
                Text(song.artist ?? "Unknown Artist")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Start: \(formatTime(song.startTime))")
                        .font(.caption)
                        .foregroundColor(.blue)
                    if song.endTime > 0 {
                        Text("End: \(formatTime(song.endTime))")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                audioPlayerManager.playSong(Song(from: song))
            }) {
                Image(systemName: audioPlayerManager.isPlaying && 
                      audioPlayerManager.currentSong?.id == song.id ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct PlayerControlsView: View {
    let song: Song
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text(song.title)
                .font(.headline)
            Text(song.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                Button(action: {
                    audioPlayerManager.skipBackward()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                
                Button(action: {
                    audioPlayerManager.togglePlayPause()
                }) {
                    Image(systemName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: {
                    audioPlayerManager.skipForward()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
            }
            .foregroundColor(.blue)
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AudioPlayerManager())
    }
}
