//
//  CoalescingTests.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Parsley
import Spork

class SequencingTests: XCTestCase {
    func testS() {
        XCTAssertTrue(try! 12 == coalesce(token(3), token(5), token(12)).parse([12, 3]))
        XCTAssertTrue(try! 3 == coalesce(token(3), token(5), token(12)).parse([3, 12]))
        XCTAssertTrue(try! 3 == (token(7) ?? token(12) ?? token(3)).parse([3, 12]))
        XCTAssertNil(try? coalesce(token(3), token(5), token(12)).parse([7, 3, 12]))
    }
    
    func testEither() {
        switch try! either(token(3), many(lessThanFour)).parse([3, 2, 1, 0]) {
        case let .Left(v): XCTAssertEqual(3, v)
        default: XCTFail()
        }
        switch try! either(token(2), many(lessThanFour)).parse([3, 2, 1, 0]) {
        case let .Right(v): XCTAssertEqual([3, 2, 1, 0], v)
        default: XCTFail()
        }
    }
}