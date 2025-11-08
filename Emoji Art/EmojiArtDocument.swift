//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import SwiftUI

typealias Emoji = EmojiArt.Emoji

class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
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
    
    func removeEmoji(_ emoji: Emoji) {
        emojiArt.removeEmoji(withId: emoji.id)
    }
    
    func move(_ id: Emoji.ID, by offset: CGOffset) {
        if let emoji = emojiArt[id] {
            emojiArt[emoji].position += offset
        }
    }
    
    func scale (_ id: Emoji.ID, by scale: CGFloat) {
        if let emoji = emojiArt[id] {
            emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
        }
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
    
    static func +(lhs: Emoji.Position, offset: CGOffset) -> Emoji.Position {
        Emoji.Position(x: lhs.x + Int(offset.width), y: lhs.y - Int(offset.height))
    }
    
    static func +=(lhs: inout Emoji.Position, offset: CGOffset) {
        lhs.x += Int(offset.width)
        lhs.y -= Int(offset.height)
    }
}
