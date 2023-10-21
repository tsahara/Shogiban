//
//  Shogiban.swift
//  Shogiban
//
//  Created by Tomoyuki Sahara on 2023/10/21.
//

import SwiftUI

@Observable class Shogiban: Identifiable {
    var banSize = CGSize()
}

extension EnvironmentValues {
    var shogiban: Shogiban {
        get { self[ShogibanKey.self] }
        set { self[ShogibanKey.self] = newValue }
    }
}

private struct ShogibanKey: EnvironmentKey {
    static var defaultValue = Shogiban()
}

