//
//  PaletteList.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-11-15.
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    @State var presentEditor = false
    
    var body: some View {
        List {
            ForEach(store.palettes) { palette in
                NavigationLink(value: palette.id) {
                    VStack(alignment: .leading) {
                        Text(palette.name)
                        Text(palette.emojis).lineLimit(1)
                    }
                }
            }
            .onDelete { indexSet in
                withAnimation {
                    store.palettes.remove(atOffsets: indexSet)
                }
            }
            .onMove { (indexSet, newOffset) in
                withAnimation {
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
        }
        .navigationDestination(for: Palette.ID.self) { paletteId in
            if let index = store.palettes.firstIndex(where: { $0.id == paletteId }) {
                PaletteEditor(palette: $store.palettes[index])
                    .font(nil)
            }
        }
        .navigationDestination(isPresented: $presentEditor) {
            PaletteEditor(palette: $store.palettes[store.activeIndex])
                .font(nil)
        }
        .navigationTitle("\(store.name) Palettes")
        .toolbar {
            Button {
                store.insert(name: "", emojis: "")
                presentEditor = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct PaletteView: View {
    var palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji)
                    .font(.system(size: 400))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name)
    }
}

#Preview {
    PaletteList()
        .environmentObject(PaletteStore(named: "Preview"))
}
