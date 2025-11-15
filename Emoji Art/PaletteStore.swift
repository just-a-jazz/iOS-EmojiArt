//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-11-05.
//

import SwiftUI

extension UserDefaults {
    func palettes(for name: String) -> [Palette]? {
        if let data = data(forKey: name) {
            return try? JSONDecoder().decode([Palette].self, from: data)
        }
        return nil
    }
    
    func set(_ palettes: [Palette], for name: String) {
        if let data = try? JSONEncoder().encode(palettes) {
            set(data, forKey: name)
        }
    }
}

class PaletteStore: ObservableObject {
    
    let name: String
    private var userDefaultsKey: String { "PaletteStore:\(name)" }
    var palettes: [Palette] {
        get {
            UserDefaults.standard.palettes(for: name) ?? Palette.builtins
        }
        set {
            if !newValue.isEmpty {
                UserDefaults.standard.set(newValue, for: name)
                objectWillChange.send()
            }
        }
    }
    
    init(named name: String) {
        self.name = name
    }
    
    @Published var _activeIndex = 0
    
    var activeIndex: Int {
        get {
            getBoundsCheckedActiveIndex(at: _activeIndex)
        }
        set {
            _activeIndex = getBoundsCheckedActiveIndex(at: newValue)
        }
    }
    
    func getBoundsCheckedActiveIndex(at index: Int) -> Int {
        var index = index % palettes.count
        if index < 0 {
            index += palettes.count
        }
        return index
    }
    
    // MARK: - Adding Palettes
    
    // these functions are the recommended way to add Palettes to the PaletteStore
    // since they try to avoid duplication of Identifiable-ly identical Palettes
    // by first removing/replacing any Palette with the same id that is already in palettes
    // it does not "remedy" existing duplication, it just does not "cause" new duplication
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) { // "at" default is cursorIndex
        let insertionIndex = getBoundsCheckedActiveIndex(at: insertionIndex ?? activeIndex)
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) { // at end of palettes
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
                palettes.append(palette)
            }
        } else {
            palettes.append(palette)
        }
    }
    
    func append(name: String, emojis: String) {
        append(Palette(name: name, emojis: emojis))
    }
}
