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
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
        }
    }
}
