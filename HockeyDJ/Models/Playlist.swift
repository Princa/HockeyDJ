//
//  Playlist.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import Foundation

struct Playlist: Identifiable, Codable {
    var id: UUID
    var name: String
    var createdDate: Date
    var songs: [Song]
    
    init(id: UUID = UUID(),
         name: String,
         createdDate: Date = Date(),
         songs: [Song] = []) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.songs = songs
    }
    
    // Convert from Core Data entity
    init(from entity: PlaylistEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.createdDate = entity.createdDate ?? Date()
        
        if let songEntities = entity.songs?.array as? [SongEntity] {
            self.songs = songEntities.map { Song(from: $0) }
        } else {
            self.songs = []
        }
    }
}
