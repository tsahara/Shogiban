//
//  Shogiban.swift
//  Shogiban
//
//  Created by 佐原具幸 on 2023/10/14.
//

import SwiftUI

struct ShogibanView: View {
    @Bindable var kyokumen: Kyokumen
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
                        p.addLine(to: CGPoint(x: geo.fuchi.maxX, y: y))
                    }
                    for i in 1...8 {  // vertical lines
                        let x = geo.fuchi.minX + geo.masuHeight * CGFloat(i)
                        let y = geo.fuchi.minY
                        p.move(to: CGPoint(x: x, y: y))
                        p.addLine(to: CGPoint(x: x, y: geo.fuchi.maxY))
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

                    let numberFont = Font.system(size: geo.squareSize * 0.4)
                    for x in 1...9 {
                        let m: CGRect = geo.masuRect(x, 1)
                        context.draw(
                            Text(x_index_strs[x-1]).font(numberFont),
                            at: CGPoint(x: m.midX,
                                        y: m.minY - geo.numberPaddingX),
                            anchor: .bottom)
                    }
                    for y in 1...9 {
                        let m: CGRect = geo.masuRect(1, y)
                        context.draw(
                            Text(y_index_strs[y-1]).font(numberFont),
                            at: CGPoint(x: m.maxX + geo.numberPaddingY,
                                        y: m.midY),
                            anchor: .leading)
                    }
                }
                .background(geometryInspector)

                pieceStandView(geo, .black)
                pieceStandView(geo, .white)

                ForEach(kyokumen.piecesOnBoard()) { square in
                    let deg = (square.player == .black ? 0.0 : 180.0)
                    Text(square.piece!.char())
                        .font(.system(size: geo.squareSize))
                        .rotationEffect(.degrees(deg))
                        .position(geo.masuRect(square.x, square.y).center)
                }
            }
        }
    }

    var geometryInspector: some View {
        GeometryReader { geometry -> AnyView in
            DispatchQueue.main.async {
                shogiban.banSize = geometry.size
            }
            return AnyView(Color.white)
        }
    }

    func starPath(geo: ShogibanGeometry, x: Int, y: Int) -> Path {
        let d = geo.masuWidth / 8
        let star_rect = CGRect(
            origin: geo.masuRect(x, y + 1).origin .applying(.init(translationX: -d / 2, y: -d / 2)),
            size: CGSize(width: d, height: d))
        return Circle().path(in: star_rect)
    }

    func makePieceStandString(_ player: Player) -> String {
        let prefix = player == .black ? "☗先手 " : "☖後手 "
        var str = prefix
        [.rook, .bishop, .gold, .silver, .knight, .lance].forEach {
            (piece: Piece) in
            let count = kyokumen.has(piece, player)
            str += String(repeating: piece.char(), count: count)
        }

        let paunCount = kyokumen.has(.paun, player)
        if paunCount == 1 {
            str += "歩"
        } else if paunCount >= 2 {
            let fmt = NumberFormatter()
            fmt.numberStyle = .spellOut
            fmt.locale = .init(identifier: "ja-JP")
            str += "歩" + fmt.string(from: NSNumber(value: paunCount))!
        }
        if str == prefix { str += "なし" }

        return str
    }

    func pieceStandView(_ geo: ShogibanGeometry, _ player: Player) -> some View {
        let charSize = geo.squareSize * 0.7

        let x: CGFloat, deg: Double
        if player == .black {
            x = geo.fuchi.maxX + geo.squareSize * 1.2
            deg = 0.0
        } else {
            x = geo.fuchi.minX - geo.squareSize * 0.7
            deg = 180.0
        }

        return Canvas { context, _ in
            let handFont = Font.system(size: charSize)
            let str = makePieceStandString(player)

            for (index, char) in str.enumerated() {
                let offset = charSize * CGFloat(str.count - index)
                context.draw(Text(String(char)).font(handFont),
                             at: CGPoint(x: 0,
                                         y: geo.fuchi.maxY - offset),
                             anchor: .bottomLeading)
            }
        }
        .rotationEffect(.degrees(deg))
        .frame(width: charSize, height: geo.fuchi.height)
        .position(x: x, y: geo.fuchi.midY)
    }
}

struct ShogibanGeometry {
    let parent: GeometryProxy

    let unit: CGFloat
    let fuchi: CGRect
    let squareSize: CGFloat

    init(parent: GeometryProxy) {
        self.parent = parent

        self.unit = parent.size.height / 10.4

        self.fuchi = CGRect(x: unit * 1.3, y: unit * 0.7,
                            width: unit * 9, height: unit * 9)

        self.squareSize = unit * 0.85
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

struct Square: Identifiable {
    let x: Int
    let y: Int
    let piece: Piece?
    let player: Player?

    var id: Int {
        // Note: x < 16, y < 16, piece < 16, and player < 4
        if piece == nil {
            0 + x << 1 + y << 5
        } else {
            1 + x << 1 + y << 5 + piece!.rawValue << 9 + player!.rawValue << 13
        }
    }
}

@Observable
class Kyokumen {
    var masume: [(piece: Piece?, player: Player?)]
    var mochigomaSente: [Piece: Int]
    var mochigomaGote: [Piece: Int]

    init() {
        masume = Array(repeating: (piece: nil, player: nil),
                       count: 81)
        mochigomaSente = [:]
        mochigomaGote = [:]

        set(5, 1, .king, .white)
        set(5, 9, .king, .black)
        set(4, 1, .gold, .white)
        set(6, 9, .gold, .black)
        set(6, 1, .gold, .white)
        set(4, 9, .gold, .black)
        set(3, 1, .silver, .white)
        set(7, 9, .silver, .black)
        set(7, 1, .silver, .white)
        set(3, 9, .silver, .black)
        set(2, 1, .knight, .white)
        set(8, 9, .knight, .black)
        set(8, 1, .knight, .white)
        set(2, 9, .knight, .black)
        set(1, 1, .lance, .white)
        set(9, 9, .lance, .black)
        set(9, 1, .lance, .white)
        set(1, 9, .lance, .black)
        set(2, 2, .bishop, .white)
        set(8, 8, .bishop, .black)
        set(8, 2, .rook, .white)
        set(2, 8, .rook, .black)
        for x in 1...9 {
            set(x, 3, .paun, .white)
            set(x, 7, .paun, .black)
        }
    }

    func piecesOnBoard() -> [Square] {
        var result = [Square]()
        for row in 1...9 {
            for column in 1...9 {
                let (piece, player) = get(column, row)
                if piece != nil {
                    result.append(Square(x: column,
                                         y: row,
                                         piece: piece,
                                         player: player))
                }
            }
        }
        return result
    }

    func get(_ x: Int, _ y: Int) -> (Piece?, Player?) {
        precondition(x >= 1 && x <= 9)
        precondition(y >= 1 && y <= 9)
        return masume[(x - 1) + (y - 1) * 9]
    }

    func set(_ x: Int, _ y: Int, _ piece: Piece?, _ player: Player?) {
        precondition(x >= 1 && x <= 9)
        precondition(y >= 1 && y <= 9)
        masume[(x - 1) + (y - 1) * 9] = (piece, player)
    }

    func capture(_ piece: Piece, _ player: Player) {
        if player == .black {
            let n = self.mochigomaSente[piece] ?? 0
            self.mochigomaSente[piece] = n + 1
        } else {
            let n = self.mochigomaGote[piece] ?? 0
            self.mochigomaGote[piece] = n + 1
        }
    }

    func drop(_ piece: Piece, _ player: Player) {
        if player == .black {
            if (self.mochigomaSente[piece] ?? 0) <= 1 {
                mochigomaSente.removeValue(forKey: piece)
            } else {
                self.mochigomaSente[piece]! -= 1
            }
        } else {
            if (self.mochigomaGote[piece] ?? 0) <= 1 {
                mochigomaGote.removeValue(forKey: piece)
            } else {
                self.mochigomaGote[piece]! -= 1
            }
        }
    }

    func has(_ piece: Piece, _ player: Player) -> Int {
        if player == .black {
            return mochigomaSente[piece] ?? 0
        } else {
            return mochigomaGote[piece] ?? 0
        }
    }

    func clear() {
        for x in 1...9 {
            for y in 1...9 {
                set(x, y, nil, nil)
            }
        }
        mochigomaSente = [:]
        mochigomaGote = [:]
    }

    static func charToPiecePlayer(_ ch: Character) -> (Piece?, Player?) {
        switch ch {
        case "P": (.paun,   .black)
        case "L": (.lance,  .black)
        case "N": (.knight, .black)
        case "S": (.silver, .black)
        case "G": (.gold,   .black)
        case "B": (.bishop, .black)
        case "R": (.rook,   .black)
        case "K": (.king,   .black)
        case "p": (.paun,   .white)
        case "l": (.lance,  .white)
        case "n": (.knight, .white)
        case "s": (.silver, .white)
        case "g": (.gold,   .white)
        case "b": (.bishop, .white)
        case "r": (.rook,   .white)
        case "k": (.king,   .white)
        default:  (nil, nil)
        }
    }

    func read(sfen: String) -> Bool {
        self.clear()

        enum Phase {
            case ban, sengo, mochigoma
        }
        var phase = Phase.ban
        var piece: Piece? = nil
        var player: Player? = nil
        var promoted = false
        var x = 9
        var y = 1
        var count = 0

        for ch in sfen {
            if phase == .ban {
                switch ch {
                case "1"..."9":
                    x -= ch.wholeNumberValue!
                    piece = nil
                case "/":
                    y += 1
                    x = 9
                    piece = nil
                    continue
                case "+":
                    promoted = true
                case " ":
                    if y == 9 {
                        phase = .sengo
                        continue
                    }
                    // ignore other space chars
                default:
                    (piece, player) = Kyokumen.charToPiecePlayer(ch)
                    if piece == nil {
                        return false  // invalid char
                    }
                }

                if piece != nil {
                    if x <= 0 || y >= 10 {
                        return false
                    }
                    if promoted {
                        piece = piece?.promote()
                    }
                    player = ch.isUppercase ? .black : .white
                    self.set(x, y, piece, player)
                    piece = nil
                    promoted = false
                    x -= 1
                }
            } else if phase == .sengo {
                switch ch {
                case "b":
                    phase = .mochigoma
                    piece = nil
                case "w":
                    phase = .mochigoma
                    piece = nil
                case " ": continue
                default:
                    return false
                }
            } else if phase == .mochigoma {
                switch ch {
                case "1"..."9":
                    count = count * 10 + ch.wholeNumberValue!
                    continue
                case "-":
                    // both players have no pieces
                    break
                case " ":
                    continue
                default:
                    (piece, player) = Kyokumen.charToPiecePlayer(ch)
                    if piece == nil {
                        return false  // invalid char
                    }
                }
                if piece != nil {
                    if count == 0 {
                        count = 1
                    }
                    for _ in 1...count {
                        self.capture(piece!, player!)
                    }
                    piece = nil
                    count = 0
                }
            }
        }
        return true
    }
}

#Preview {
    ShogibanView(kyokumen: Kyokumen())
}
