//
//  ShogibanTests.swift
//  ShogibanTests
//
//  Created by 佐原具幸 on 2023/10/14.
//

import XCTest
@testable import Shogiban

final class ShogibanTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

final class KyokumenTests: XCTestCase {
    let k = Kyokumen()

    func testClear() throws {
        XCTAssertEqual(k.get(1, 1), .kyoushaG)
        k.clear()
        XCTAssertEqual(k.get(1, 1), .empty)
    }

    func testRead() throws {
        let shokei = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
        XCTAssertTrue(k.read(sfen: shokei))
        XCTAssertEqual(k.get(1, 1), .kyoushaG)
        XCTAssertEqual(k.get(5, 3), .fuG)
        XCTAssertEqual(k.get(5, 7), .fuS)
        XCTAssertEqual(k.get(9, 9), .kyoushaS)

        // 第13期竜王戦七番勝負第７局
        let k2 = "l6nl/5+P3/2np3k1/p1p2S2p/3P2Sp1/1pPb2P1P/PP2+r1NS1/R5GK1/LN6L b Gb2gs5p 1"
        let kyokumenArray: [[Koma]] = [
            [ .kyoushaG, .empty, .empty, .empty, .empty, .empty, .empty, .keimaG, .kyoushaG],
            [ .empty, .empty, .empty, .empty, .empty, .fuS, .empty, .empty, .empty ],
            [ .empty, .empty, .keimaG, .fuG, .empty, .empty, .empty, .gyokuG, .empty ],
            [ .fuG, .empty, .fuG, .empty, .empty, .ginS, .empty, .empty, .fuG ],
            [ .empty, .empty, .empty, .fuS, .empty, .empty, .ginS, .fuG, .empty ],
            [ .empty, .fuG, .fuS, .kakuG, .empty, .empty, .fuS, .empty, .fuS ],
            [ .fuS, .fuS, .empty, .empty, .hishaG, .empty, .keimaS, .ginS, .empty ],
            [ .hishaS, .empty, .empty, .empty, .empty, .empty, .kinS, .gyokuS, .empty ],
            [ .kyoushaS, .keimaS, .empty, .empty, .empty, .empty, .empty, .empty, .kyoushaS ],
        ]
        XCTAssertTrue(k.read(sfen: k2))
        for y in 0..<9 {
            for x in 0..<9 {
                let komaExpected = kyokumenArray[y][x]
                let komaActual = k.get(9 - x, 1 + y)
                XCTAssert(komaExpected == komaActual,
                          "\(komaActual) at (\(9-x),\(1+y)) should be \(komaExpected)")
            }
        }
        XCTAssertEqual(k.has(.kinS), 1)
        XCTAssertEqual(k.has(.fuS), 0)
        XCTAssertEqual(k.has(.kakuG), 1)
        XCTAssertEqual(k.has(.kinG), 2)
        XCTAssertEqual(k.has(.ginG), 1)
        XCTAssertEqual(k.has(.fuG), 5)
    }
}
