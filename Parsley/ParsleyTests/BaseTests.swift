//
//  BaseTests.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
import Parsley
import Spork

class BaseTests: XCTestCase {
    
    func testPure() {
        XCTAssertEqual("Jaden", try? pure("Jaden").parse("Hello world".characters))
    }
    
    func testAny() {
        XCTAssertEqual("H", try? any().parse("Hello world".characters))
    }
    
    func testSatisfy() {
        let parser = satisfy { $0 > 0 }
        XCTAssertEqual(1, try? parser.parse([1, 2, 3]))
        XCTAssertEqual(nil, try? parser.parse([0, 1, 2, 3]))
    }
    
    func testToken() {
        let parser = token(0)
        XCTAssertEqual(0, try? parser.parse([0]))
        XCTAssertEqual(nil, try? parser.parse([1]))
    }
    
    func testWithinInterval() {
        let parser = within(2...4)
        XCTAssertEqual(3, try? parser.parse([3]))
        XCTAssertEqual(nil, try? parser.parse([5]))
    }
    
    func testWithinSequence() {
        let parser = oneOf([1, 2, 3, 5, 8])
        XCTAssertEqual(5, try? parser.parse([5]))
        XCTAssertEqual(nil, try? parser.parse([6]))
    }
    
    func testEnd() {
        do {
            _ = try end().parse("".characters)
        } catch {
            XCTFail()
        }
    }
    
    func testTerminating() {
        do {
            _ = try terminating(sequence(token(0), token(1))).parse(0...1)
        } catch {
            XCTFail()
        }
        do {
            _ = try terminating(sequence(token(0), token(1))).parse(0...2)
            XCTFail()
        } catch {
        }
    }
}
