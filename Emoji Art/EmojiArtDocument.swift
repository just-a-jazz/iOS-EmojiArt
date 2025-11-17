//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import SwiftUI

typealias Emoji = EmojiArt.Emoji

class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt: EmojiArt = EmojiArt() {
        didSet {
            autosave(emojiArt)
            if emojiArt.background != oldValue.background {
                Task {
                    await setBackground()
                }
            }
        }
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var bbox: CGRect {
        var bbox = CGRect.zero
        for emoji in emojiArt.emojis {
            bbox = bbox.union(emoji.bbox)
        }
        if let backgroundSize = background.uiImage?.size {
            bbox = bbox.union(CGRect(center: .zero, size: backgroundSize))
        }
        return bbox
    }
    
    private var autosaveURL = URL.documentsDirectory.appendingPathComponent("emojiArt.json")
    
    init() {
        if let savedData = try? retrieveSavedData(),
           let savedEmojiArt = try? emojiArt.decode(from: savedData) {
            emojiArt = savedEmojiArt
        }
    }
    
    func autosave(_ emojiArt: EmojiArt) {
        save(to: autosaveURL)
        print("Autosaved to: \(autosaveURL)")
    }
    
    func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving - \(error.localizedDescription)")
        }
    }
    
    func retrieveSavedData() throws -> Data? {
        return try Data(contentsOf: autosaveURL)
    }
    
    // MARK: - Background
    @Published var background: Background = .none
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let image): return image
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isBeingFetched: Bool {
            urlBeingFetched != nil
        }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
    }
    
    @MainActor
    private func setBackground() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch {
                background = .failed("Couldn't set background: \(error.localizedDescription)")
            }
        } else {
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let image = UIImage(data: data) {
            return image
        } else {
            throw FetchError.invalidImageData
        }
    }
    
    enum FetchError: Error {
        case invalidImageData
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
    
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
        )
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
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
