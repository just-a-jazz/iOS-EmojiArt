//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-10-23.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @Environment(\.undoManager) var undoManager
    
    @ObservedObject var document: EmojiArtDocument
    @StateObject private var paletteStore = PaletteStore(named: "Shared")
    
    @ScaledMetric var paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            UndoButton()
        }
        .environmentObject(paletteStore)
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    @State private var showBackgroundFailureAlert = false
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.background.isBeingFetched {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * (backgroundIsActive ? gestureZoom : 1))
                    .offset(pan + gesturePan)
            }
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .gesture(zoomGesture.simultaneously(with: backgroundIsActive ? panGesture : nil))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, to: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = (reason != nil)
            }
            .onChange(of: document.background.uiImage) { _, uiImage in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .alert(
                "Document Background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { _ in
                    Button("OK", role: .cancel) {}
                },
                message: { reason in
                    Text(reason)
                }
            )
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
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
        if let image = document.background.uiImage {
            Image(uiImage: image)
                .position(Emoji.Position.zero.in(geometry))
                .onTapGesture {
                    selectedEmojis = []
                }
        }
        ForEach(document.emojis) { emoji in
            emojiView(for: emoji, in: geometry)
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
//            .contextMenu {
//                AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
//                    document.removeEmoji(emoji, undoWith: undoManager)
//                }
//            }
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
                    document.move(emoji, by: endPanOffset.translation, undoWith: undoManager)
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
                        document.scale(emoji, by: endZoomValue, undoWith: undoManager)
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
                document.setBackground(url, undoWith: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(for: location, in: geometry),
                    withSize: paletteEmojiSize / zoom,
                    undoWith: undoManager)
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
        static let selectedEmojiLineWidth = CGFloat(5)
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
