//
//  Shogiban.swift
//  Shogiban
//
//  Created by 佐原具幸 on 2023/10/14.
//

import SwiftUI

struct ShogibanView: View {
    var kyokumen: Kyokumen
    @Environment(\.shogiban) var shogiban

    var body: some View {
        GeometryReader { geometry in
            let geo = ShogibanGeometry(parent: geometry)

            ZStack {
                Canvas {
                    context, size in

                    let frame_color = GraphicsContext.Shading.color(.black)

                    // Outer Frame
                    context.stroke(Path(geo.fuchi), with: frame_color, lineWidth: 2)

                    // Inner Lines
                    var p = Path()
                    for i in 1...8 {  // horizontal lines
                        let x = geo.fuchi.minX
                        let y = geo.fuchi.minY + geo.masuHeight * CGFloat(i)
                        p.move(to: CGPoint(x: x, y: y))
                        p.addLine(to: CGPoint(x: x + geo.fuchi.width, y: y))
                    }
                    for i in 1...8 {  // vertical lines
                        let x = geo.fuchi.minX + geo.masuHeight * CGFloat(i)
                        let y = geo.fuchi.minY
                        p.move(to: CGPoint(x: x, y: y))
                        p.addLine(to: CGPoint(x: x, y: y + geo.fuchi.height))
                    }
                    context.stroke(p, with: frame_color)

                    // 4 Stars
                    context.fill(starPath(geo: geo, x: 3, y: 3), with: frame_color)
                    context.fill(starPath(geo: geo, x: 3, y: 6), with: frame_color)
                    context.fill(starPath(geo: geo, x: 6, y: 3), with: frame_color)
                    context.fill(starPath(geo: geo, x: 6, y: 6), with: frame_color)

                    // numbers
                    let x_index_strs = ["１", "２", "３", "４", "５", "６", "７", "８", "９"]
                    let y_index_strs = ["一", "二", "三", "四", "五", "六" ,"七", "八", "九"]
                    for x in 1...9 {
                        let m: CGRect = geo.masuRect(x, 1)
                        context.draw(Text(x_index_strs[x-1]), at: CGPoint(x: m.midX, y: m.minY - geo.numberPaddingX), anchor: .bottom)
                    }
                    for y in 1...9 {
                        let m: CGRect = geo.masuRect(1, y)
                        context.draw(Text(y_index_strs[y-1]),
                                     at: CGPoint(x: m.maxX + geo.numberPaddingY, y: m.midY),
                                     anchor: .leading)
                    }
                }
                .background(GeometryReader { g2 -> Color in
                    DispatchQueue.main.async {
                        shogiban.banSize = g2.size
                    }
                    return Color.white
                })

                let kyokumen = Kyokumen()
                ForEach(kyokumen.koma_all()) { masu in
                    Text(masu.koma.char())
                        .font(.system(size: geo.komaSize))
                        .rotationEffect(.degrees(masu.is_sente() ? 0 : 180))
                        .position(geo.masuRect(masu.x, masu.y).center)
                }
            }
        }
    }

    func starPath(geo: ShogibanGeometry, x: Int, y: Int) -> Path {
        let d = geo.masuWidth / 5
        let star_rect = CGRect(
            origin: geo.masuRect(x, y + 1).origin .applying(.init(translationX: -d / 2, y: -d / 2)),
            size: CGSize(width: d, height: d))
        return Circle().path(in: star_rect)
    }
}

struct ShogibanGeometry {
    let parent: GeometryProxy

    let unit: CGFloat
    let fuchi: CGRect
    let komaSize: CGFloat

    init(parent: GeometryProxy) {
        self.parent = parent

        self.unit = parent.size.height / 10.0

        self.fuchi = CGRect(x: unit * 0.5, y: unit * 0.5,
                            width: unit * 9, height: unit * 9)

        self.komaSize = unit * 0.85
    }

    func masuRect(_ x: Int, _ y: Int) -> CGRect {
        precondition(x >= 1 && x <= 9)
        precondition(y >= 1 && y <= 9)
        return CGRect(x: fuchi.maxX - unit * CGFloat(x),
                      y: fuchi.minY + unit * CGFloat(y - 1),
                      width: unit,
                      height: unit)
    }

    var masuHeight: CGFloat { return unit }
    var masuWidth: CGFloat { return unit }

    let numberPaddingX = 2.0
    let numberPaddingY = 5.0
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
}

enum Koma: Int {
    case fuS, kyoushaS, keimaS, ginS, kinS, kakuS, hishaS, gyokuS
    case fuG, kyoushaG, keimaG, ginG, kinG, kakuG, hishaG, gyokuG
    case empty, error

    func char() -> String {
        switch self {
        case .fuS, .fuG: return "歩"
        case .kyoushaS, .kyoushaG: return "香"
        case .keimaS, .keimaG: return "桂"
        case .ginS, .ginG: return "銀"
        case .kinS, .kinG: return "金"
        case .kakuS, .kakuG: return "角"
        case .hishaS, .hishaG: return "飛"
        case .gyokuS, .gyokuG: return "玉"
        case .empty: return ""
        case .error: return "？"
        }
    }
}

struct MasuState: Identifiable {
    let x: Int
    let y: Int
    let koma: Koma

    var id: Int {
        x + (y * 9) + (koma.rawValue * 81)
    }

    func is_sente() -> Bool {
        return (koma == .fuS || koma == .kyoushaS || koma == .keimaS ||
                koma == .ginS || koma == .kinS || koma == .kakuS ||
                koma == .hishaS || koma == .gyokuS)
    }

    func is_gote() -> Bool {
        return !is_sente()
    }
}

struct Kyokumen {
    var masume: [Koma]

    init() {
        masume = Array(repeating: .empty, count: 81)
        set(5, 1, .gyokuG)
        set(5, 9, .gyokuS)
        set(4, 1, .kinG)
        set(6, 9, .kinS)
        set(6, 1, .kinG)
        set(4, 9, .kinS)
        set(3, 1, .ginG)
        set(7, 9, .ginS)
        set(7, 1, .ginG)
        set(3, 9, .ginS)
        set(2, 1, .keimaG)
        set(8, 9, .keimaS)
        set(8, 1, .keimaG)
        set(2, 9, .keimaS)
        set(1, 1, .kyoushaG)
        set(9, 9, .kyoushaS)
        set(9, 1, .kyoushaG)
        set(1, 9, .kyoushaS)
        set(2, 2, .kakuG)
        set(8, 8, .kakuS)
        set(8, 2, .hishaG)
        set(2, 8, .hishaS)
        for x in 1...9 {
            set(x, 3, .fuG)
            set(x, 7, .fuS)
        }
    }

    func koma_all() -> [MasuState] {
        var result = [MasuState]()
        for y in 1...9 {
            for x in 1...9 {
                let k = get(x, y)
                if k != .empty && k != .error {
                    result.append(MasuState(x: x, y: y, koma: k))
                }
            }
        }
        return result
    }

    func get(_ x: Int, _ y: Int) -> Koma {
        precondition(x >= 1 && x <= 9)
        precondition(y >= 1 && y <= 9)
        return masume[(x - 1) + (y - 1) * 9]
    }

    mutating func set(_ x: Int, _ y: Int, _ koma: Koma) {
        precondition(x >= 1 && x <= 9)
        precondition(y >= 1 && y <= 9)
        masume[(x - 1) + (y - 1) * 9] = koma
    }
}

#Preview {
    ShogibanView(kyokumen: Kyokumen())
}
