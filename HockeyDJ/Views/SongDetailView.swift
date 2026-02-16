//
//  SongDetailView.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI
import CoreData

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
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSong()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSongData()
            }
        }
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
