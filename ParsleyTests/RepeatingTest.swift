//
//  RepeatingTest.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Parsley
import Spork

let lessThanFour: Parser<Int, Int> = satisfy{ $0 < 4 }
let even: Parser<Int, Int> = satisfy{ $0 % 2 == 0 }
let odd: Parser<Int, Int> = satisfy{ $0 % 2 == 1 }

class RepeatingTests: XCTestCase {
    func testMany() {
        XCTAssertEqual([0, 1, 2, 3], try! many(lessThanFour).parse(0...10))
        XCTAssertEqual([], try! many(lessThanFour).parse(8...10))
    }
    
    func testMany1() {
        XCTAssertEqual([0, 1, 2, 3], try! many1(lessThanFour).parse(0...10))
        XCTAssertEqual([3], try! many1(lessThanFour).parse(3...10))
        XCTAssertNil(try? many1(lessThanFour).parse(8...10))
    }
    
    func testManyThen() {
        XCTAssertTrue({
            let (results, then) = try! many(lessThanFour, then: even).parse(0...10)
            return results == [0, 1, 2, 3] && then == 4
        }())
        XCTAssertTrue({
            let (results, then) = try! many(lessThanFour, then: odd).parse(0...10)
            return results == [0, 1, 2] && then == 3
        }())
        XCTAssertTrue({
            let (results, then) = try! many(lessThanFour, then: even).parse([0, 1, 2, 6, 2, 7, 8, 9])
            return results == [0, 1, 2] && then == 6
        }())
        XCTAssertTrue({
            let (results, then) = try! many(lessThanFour, then: even).parse([12, 15, 3, 6])
            return results == [] && then == 12
        }())
    }
    
    func testFewThen() {
        XCTAssertTrue({
            let (results, then) = try! few(lessThanFour, then: even).parse(0...10)
            return results == [] && then == 0
            }())
        XCTAssertTrue({
            let (results, then) = try! few(lessThanFour, then: odd).parse(0...10)
            return results == [0] && then == 1
            }())
        XCTAssertTrue({
            let (results, then) = try! few(lessThanFour, then: even).parse([1, 3, 1, 3, 2, 3, 2, 3])
            return results == [1, 3, 1, 3] && then == 2
            }())
        XCTAssertTrue({
            let (results, then) = try! few(lessThanFour, then: even).parse([12, 15, 3, 6])
            return results == [] && then == 12
        }())
        XCTAssertNil(try? few(lessThanFour, then: even).parse([13, 15, 3, 6]))
    }
    
    func testRepeated() {
        XCTAssertEqual([0, 1, 2], try! repeated(lessThanFour, exactCount: 3).parse(0...10))
        XCTAssertNil(try? repeated(lessThanFour, exactCount: 5).parse(0...10))
        XCTAssertEqual([0, 1, 2, 3], try! repeated(lessThanFour, minCount: 2).parse(0...10))
        XCTAssertNil(try? repeated(lessThanFour, minCount: 5).parse(0...10))
        XCTAssertEqual([0, 1], try! repeated(lessThanFour, maxCount: 2).parse(0...10))
        XCTAssertEqual([0, 1, 2, 3], try! repeated(lessThanFour, maxCount: 5).parse(0...10))
        XCTAssertEqual([0, 1, 2, 3], try! repeated(lessThanFour, betweenCount: 2...5).parse(0...10))
        XCTAssertEqual([0, 1, 2], try! repeated(lessThanFour, betweenCount: 1...3).parse(0...10))
        XCTAssertNil(try? repeated(lessThanFour, betweenCount: 5...7).parse(0...10))
    }
}
