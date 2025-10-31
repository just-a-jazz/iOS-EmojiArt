//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import Foundation

struct EmojiArt {
    var background: URL?
    
    private(set) var emojis = [Emoji]()
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, withSize size: Int) {
        uniqueEmojiId += 1
        emojis.append(
            Emoji(
                content: emoji,
                position: position,
                size: size,
                id: uniqueEmojiId
            )
        )
    }
    
    struct Emoji: Identifiable {
        let content: String
        var position: Position
        var size: Int
        let id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Position(x: 0, y: 0)
        }
    }
}
