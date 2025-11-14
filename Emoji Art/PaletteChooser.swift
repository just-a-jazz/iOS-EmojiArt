//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-11-06.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.activeIndex])
        }
        .clipped()
    }
    
    var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.activeIndex += 1
        }
        .contextMenu {
            gotoMenu
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.palettes.remove(at: store.activeIndex)
            }
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.id)
        .transition(.asymmetric(insertion: .rollUp, removal: .rollUp))
        
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(store.palettes) { palette in
                AnimatedActionButton(palette.name) {
                    if let index = store.palettes.firstIndex(where: { $0.id == palette.id }) {
                        store.activeIndex = index
                    }
                }
            }
            
        } label: {
            Label("Go to", systemImage: "text.insert")
        }
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
                       
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}


#Preview {
    PaletteChooser()
        .environmentObject(PaletteStore(named: "Preview"))
}
