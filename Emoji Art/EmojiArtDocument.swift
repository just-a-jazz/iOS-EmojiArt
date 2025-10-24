//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import Foundation

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    private var emojiArt: EmojiArt = EmojiArt()
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: - Intents
    
    func setBackground(_ url: URL) {
        emojiArt.background = url
    }
}
