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
    
    @State private var playlistURL: String = ""
    @State private var isImporting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 64))
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
                Text("Import from YouTube Music")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter a YouTube Music playlist URL or video URL to import songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    TextField("Playlist or Video URL", text: $playlistURL)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .padding(.horizontal)
                    
                    Button(action: importPlaylist) {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text(isImporting ? "Importing..." : "Import")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(playlistURL.isEmpty || isImporting ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(playlistURL.isEmpty || isImporting)
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to Import:")
                        .font(.headline)
                    
                    HStack(alignment: .top) {
                        Text("1.")
                            .fontWeight(.bold)
                        Text("Copy a YouTube Music playlist URL from your browser")
                    }
                    
                    HStack(alignment: .top) {
                        Text("2.")
                            .fontWeight(.bold)
                        Text("Paste it in the field above")
                    }
                    
                    HStack(alignment: .top) {
                        Text("3.")
                            .fontWeight(.bold)
                        Text("Tap Import to add all songs to your playlist")
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
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
        // Get current maximum order
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
            songWithOrder.update(entity: newSong)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving songs: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct YouTubeMusicImportView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeMusicImportView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
