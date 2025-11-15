//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-11-14.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    @State private var emojisToAdd = ""
    
    enum Focused {
        case name
        case addEmojis
    }
    @FocusState private var focused: Focused?
    
    private let emojiFont = Font.system(size: 40)
    
    var body: some View {
        Form {
            paletteNameSection
            emojisSection
        }
        .frame(minWidth: 300, minHeight: 350)
        .onAppear {
            adjustFocus()
        }
    }
    
    var paletteNameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)
                .focused($focused, equals: .name)
        }
    }
    
    var emojisSection: some View {
        Section(header: Text("Emojis")) {
            addEmojis
            removeEmojis
                .font(emojiFont)
        }
    }
    
    var addEmojis: some View {
        TextField("Add Emojis Here", text: $emojisToAdd)
            .focused($focused, equals: .addEmojis)
            .onChange(of: emojisToAdd) { _, emojisToAdd in
                palette.emojis = (emojisToAdd + palette.emojis)
                    .filter { $0.isEmoji }
                    .uniqued
            }
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to remove emojis")
                .font(.caption)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { $0 == emoji.first! })
                                emojisToAdd.removeAll(where: { $0 == emoji.first! })
                            }
                        }
                }
            }
        }
    }
    
    func adjustFocus() {
        if palette.name.isEmpty {
            focused = .name
        } else {
            focused = .addEmojis
        }
    }
}

#Preview {
    @Previewable @State var palette = PaletteStore(named: "Preview").palettes[0]
    
    PaletteEditor(palette: $palette)
}
