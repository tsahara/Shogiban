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

    func assertSquare(_ column: Int, _ row: Int, _ piece: Piece?, _ player: Player?, file: StaticString = #file, line: UInt = #line) {
        let (pieceActual, playerActual) = k.get(column, row)
        XCTAssertEqual(piece, pieceActual, file: file, line: line)
        XCTAssertEqual(player, playerActual, file: file, line: line)
    }

    func testInit() throws {
        assertSquare(5, 1, .king, .white)
    }

    func testClear() throws {
        assertSquare(1, 1, .lance, .white)
        k.clear()
        assertSquare(1, 1, nil, nil)
    }

    func testRead() throws {
        let shokei = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
        XCTAssertTrue(k.read(sfen: shokei))
        assertSquare(1, 1, .lance, .white)
        assertSquare(5, 3, .paun,  .white)
        assertSquare(5, 7, .paun,  .black)
        assertSquare(9, 9, .lance, .black)

        let k2 = "l6nl/5+P3/2np3k1/p1p2S2p/3P2Sp1/1pPb2P1P/PP2+r1NS1/R5GK1/LN6L b Gb2gs5p 1"
        XCTAssertTrue(k.read(sfen: k2))
        assertSquare(2, 8, .king, .black)
        assertSquare(4, 2, .paunP, .black)
        assertSquare(6, 6, .bishop, .white)
        assertSquare(5, 7, .rookP, .white)
        assertSquare(7, 9, nil, nil)

        XCTAssertEqual(k.has(.gold, .black), 1)
        XCTAssertEqual(k.has(.paun, .black), 0)
        XCTAssertEqual(k.has(.bishop, .white), 1)
        XCTAssertEqual(k.has(.gold, .white), 2)
        XCTAssertEqual(k.has(.silver, .white), 1)
        XCTAssertEqual(k.has(.paun, .white), 5)
    }
}
