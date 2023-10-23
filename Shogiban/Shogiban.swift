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

enum Player: Int {
    case black, white
}

enum Piece: Int {
    case paun, lance, knight, silver, bishop, rook, gold, king
    case paunP, lanceP, knightP, silverP, bishopP, rookP

    func promote() -> Self {
        switch self {
        case .paun:   .paunP
        case .lance:  .lanceP
        case .knight: .knightP
        case .silver: .silverP
        case .bishop: .bishopP
        case .rook:   .rookP
        default: self
        }
    }

    func char() -> String {
        return [
            .paun: "歩", .lance: "香", .knight: "桂", .silver: "銀", .bishop: "角", .rook: "飛", .gold: "金", .king: "玉", .paunP: "と", .lanceP: "杏", .knightP: "圭", .silverP: "全", .bishopP: "馬", .rookP: "竜"
        ][self]!
    }
}
