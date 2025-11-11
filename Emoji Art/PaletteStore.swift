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
}
