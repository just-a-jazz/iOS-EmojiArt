//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject private var defaultDocument = EmojiArtDocument()
    @StateObject private var paletteStore = PaletteStore(named: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
