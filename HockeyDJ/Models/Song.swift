//
//  Song.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import Foundation

struct Song: Identifiable, Codable {
    var id: UUID
    var title: String
    var artist: String
    var youtubeId: String
    var thumbnailURL: String?
    var duration: TimeInterval
    var startTime: TimeInterval
    var endTime: TimeInterval?
    var order: Int
    
    init(id: UUID = UUID(),
         title: String,
         artist: String,
         youtubeId: String,
         thumbnailURL: String? = nil,
         duration: TimeInterval,
         startTime: TimeInterval = 0,
         endTime: TimeInterval? = nil,
         order: Int = 0) {
        self.id = id
        self.title = title
        self.artist = artist
        self.youtubeId = youtubeId
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.order = order
    }
    
    // Convert from Core Data entity
    init(from entity: SongEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.artist = entity.artist ?? ""
        self.youtubeId = entity.youtubeId ?? ""
        self.thumbnailURL = entity.thumbnailURL
        self.duration = entity.duration
        self.startTime = entity.startTime
        self.endTime = entity.endTime > 0 ? entity.endTime : nil
        self.order = Int(entity.order)
    }
    
    // Update Core Data entity
    func update(entity: SongEntity) {
        entity.id = self.id
        entity.title = self.title
        entity.artist = self.artist
        entity.youtubeId = self.youtubeId
        entity.thumbnailURL = self.thumbnailURL
        entity.duration = self.duration
        entity.startTime = self.startTime
        entity.endTime = self.endTime ?? 0
        entity.order = Int16(self.order)
    }
}
