//
//  Persistence.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for preview
        for i in 0..<5 {
            let newSong = SongEntity(context: viewContext)
            newSong.id = UUID()
            newSong.title = "Sample Song \(i + 1)"
            newSong.artist = "Artist \(i + 1)"
            newSong.startTime = Double(i * 10)
            newSong.duration = 180.0
            newSong.youtubeId = "sample_id_\(i)"
            newSong.order = Int16(i)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HockeyDJ")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
