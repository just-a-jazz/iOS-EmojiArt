//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import Foundation

struct EmojiArt {
    var background: URL?
    var emojis = [Emoji]()
    
    struct Emoji {
        let content: String
        var position: Position
        var size: Int
        
        struct Position {
            var x: Int
            var y: Int
        }
    }
}
