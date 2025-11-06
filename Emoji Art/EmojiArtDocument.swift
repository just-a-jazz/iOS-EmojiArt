//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
    init() {
        emojiArt.addEmoji("🔥", at: .init(x: 300, y: 300), withSize: 200)
        emojiArt.addEmoji("❄️", at: .init(x: -300, y: -400), withSize: 90)
    }
    
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
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, withSize size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, withSize: Int(size))
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        .system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
