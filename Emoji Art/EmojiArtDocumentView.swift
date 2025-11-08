//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: Constants.paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * (backgroundIsActive ? gestureZoom : 1))
                    .offset(pan + gesturePan)
            }
            .gesture(zoomGesture.simultaneously(with: backgroundIsActive ? panGesture : nil))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, to: location, in: geometry)
            }
        }
    }
    
    @State private var selectedEmojis = Set<Emoji.ID>()
    private var backgroundIsActive: Bool {
        selectedEmojis.isEmpty
    }
    
    @GestureState private var emojiGesturePan: CGOffset = .zero
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        background(in: geometry)
        ForEach(document.emojis) { emoji in
            emojiView(for: emoji, in: geometry)
        }
    }
    
    private func background(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.zero.in(geometry))
            .onTapGesture {
                selectedEmojis = []
            }
    }
    
    private func emojiView(for emoji: Emoji, in geometry: GeometryProxy) -> some View {
        Text(emoji.content)
            .font(emoji.font)
            .border(selectedEmojis.contains(emoji.id) ? .green : .clear, width: Constants.selectedEmojiLineWidth)
            .offset(selectedEmojis.contains(emoji.id) ? emojiGesturePan : .zero)
            .scaleEffect(selectedEmojis.contains(emoji.id) ? gestureZoom : 1)
            .gesture(tap(emoji).simultaneously(with: selectedEmojis.contains(emoji.id) ? emojiPanGesture : nil))
            .position(emoji.position.in(geometry))
            .contextMenu {
                AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                    document.removeEmoji(emoji)
                }
            }
    }
    
    private func tap(_ emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
            if selectedEmojis.contains(emoji.id) {
                selectedEmojis.remove(emoji.id)
            } else {
                selectedEmojis.insert(emoji.id)
            }
        }
    }
    
    private var emojiPanGesture: some Gesture {
        DragGesture()
            .updating($emojiGesturePan) { currentPanOffset, emojiGesturePan, _ in
                emojiGesturePan = currentPanOffset.translation
            }
            .onEnded { endPanOffset in
                for emoji in selectedEmojis {
                    document.move(emoji, by: endPanOffset.translation)
                }
            }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { currentZoomValue, gestureZoom, _ in
                gestureZoom = currentZoomValue
            }
            .onEnded { endZoomValue in
                if backgroundIsActive {
                    zoom *= endZoomValue
                } else {
                    for emoji in selectedEmojis {
                        document.scale(emoji, by: endZoomValue)
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { currentPanOffset, gesturePan, _ in
                gesturePan = currentPanOffset.translation
            }
            .onEnded { endPanOffset in
                pan += endPanOffset.translation
            }
    }
    
    func drop(_ sturldatas: [Sturldata], to location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(for: location, in: geometry),
                    withSize: Constants.paletteEmojiSize / zoom)
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func emojiPosition(for point: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((point.x - center.x - pan.width) / zoom),
            y: Int((center.y - point.y + pan.height) / zoom)
        )
    }
    
    // MARK: - Constants
    private struct Constants {
        static let paletteEmojiSize: CGFloat = 40
        static let selectedEmojiLineWidth = CGFloat(5)
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
