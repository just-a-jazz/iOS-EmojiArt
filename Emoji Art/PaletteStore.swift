//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Jazz Siddiqui on 2025-11-05.
//

import SwiftUI

class PaletteStore: ObservableObject {
    let name: String
    @Published var palettes: [Palette] {
        didSet {
            if palettes.isEmpty, !oldValue.isEmpty {
                palettes = oldValue
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        self.palettes = Palette.builtins
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
