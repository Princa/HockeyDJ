//
//  ContentView.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    @State private var showingImportView = false
    
    var body: some View {
        NavigationView {
            PlaylistView()
                .navigationTitle("HockeyDJ")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingImportView = true }) {
                            Label("Import from YouTube Music", systemImage: "plus.circle")
                        }
                    }
                }
                .sheet(isPresented: $showingImportView) {
                    YouTubeMusicImportView()
                }
        }
        .environmentObject(audioPlayerManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
