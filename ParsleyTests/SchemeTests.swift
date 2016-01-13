//
//  BaseTests.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

#if false
import XCTest
import Parsley
import Spork

let bareWord = (letter.lift() + many1(letter ?? digit)).withError("bareWord")

let x =     optional(within("+-").lift())
let z =     many1(digit)

let integerLiteral = concat(
    optional(within("+-").lift()),
    many1(digit)
).withError("integerLiteral")

let floatingPointLiteral = concat(
    integerLiteral,
    character(".").lift(),
    many(digit)
).withError("floatingPointLiteral")

let stringLiteral = character("\"")

//let stringLiteral = sequence(
//    character("\"").lift().discard(),
//    many(any(), then: character("\"").discard()).map{ (l, r) in l }
//).map{ (l, r) in r }.withError("stringLiteral")

let symbol = oneOf("(", ")", "+", "-", "*", "/", "[", "]").withError("symbol")

let comment = recursive { (parser: Parser<Character, ()>) in
    sequence(
        string("/*").discard(),
        few(parser ?? any().discard(), then: string("/*")).discard()
    ).discard()
}

class SchemeTests: XCTestCase {
    func testBareWord() {
        XCTAssertEqual("blah34daDa", try? terminating(bareWord).stringify().parse("blah34daDa".characters))
        XCTAssertNil(try? terminating(bareWord).stringify().parse(" blah34daDa".characters))
        XCTAssertNil(try? terminating(bareWord).stringify().parse("35add".characters))
    }
    
    func testIntegerLiteral() {
        XCTAssertEqual("13502", try? terminating(integerLiteral).stringify().parse("13502".characters))
        XCTAssertEqual("+12", try? terminating(integerLiteral).stringify().parse("+12".characters))
        XCTAssertEqual("-0", try? terminating(integerLiteral).stringify().parse("-0".characters))
        XCTAssertNil(try? terminating(integerLiteral).stringify().parse("--32".characters))
        XCTAssertNil(try? terminating(integerLiteral).stringify().parse("32a".characters))
    }
    
    func testFloatingPointLiteral() {
        XCTAssertEqual("13.502", try? terminating(floatingPointLiteral).stringify().parse("13.502".characters))
        XCTAssertEqual("+0.12", try? terminating(floatingPointLiteral).stringify().parse("+0.12".characters))
        XCTAssertEqual("-0.", try? terminating(floatingPointLiteral).stringify().parse("-0.".characters))
        XCTAssertNil(try? terminating(floatingPointLiteral).stringify().parse("3.-32".characters))
        XCTAssertNil(try? terminating(floatingPointLiteral).stringify().parse(".3".characters))
    }
    
//    func testStringLiteral() {
//        XCTAssertEqual("13.502", try? terminating(stringLiteral).stringify().parse("\"Hello world!!!:D:D3.1415\"".characters))
//        XCTAssertEqual("+0.12", try? terminating(stringLiteral).stringify().parse("+0.12".characters))
//        XCTAssertEqual("-0.", try? terminating(stringLiteral).stringify().parse("-0.".characters))
//        XCTAssertNil(try? terminating(stringLiteral).stringify().parse("3.-32".characters))
//        XCTAssertNil(try? terminating(stringLiteral).stringify().parse(".3".characters))
//    }
}

#endif