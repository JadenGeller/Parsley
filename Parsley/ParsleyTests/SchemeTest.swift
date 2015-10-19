//
//  SchemeTest.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Foundation

import XCTest
import Parsley

enum SchemeToken {
    case BareWord(String)
    case IntegerLiteral(String)
    case FloatingPointLiteral(String)
    case StringLiteral(String)
    case Symbol(Character)
}

class SchemeTest: XCTestCase {
    
    func testScheme() {
        let whitespace = many1(anyCharacter(" ", "\n")).withError("whitespace").stringify()
        let bareWord = appending(
            letter().stringify(),
            many1(coalesce(
                letter(),
                digit()
            )).stringify()
        ).withError("bare word")
        let integerLiteral = appending(
            within("+-").stringify().otherwise(""),
            many1(digit()).stringify()
        ).withError("integer literal")
        let floatingPointLiteral = appending(
            integerLiteral,
            character(".").stringify(),
            many(digit()).stringify()
        ).withError("floating point literal")
        let stringLiteral = between(character("\""), character("\""), parse: until(character("\""))).stringify().withError("string literal")
        let symbol = within("()+-*/").withError("symbol")
        let comment = recurive { (parser: Parser<Character, String>) in
            return between(string("/*"), string("*/"), parse: appending(
                until(coalesce(string("/*"), string("*/"))).stringify(),
                appending(
                    parser,
                    until(coalesce(string("/*"), string("*/"))).stringify()
                ).otherwise("")
            ))
        }.withError("comment")
        
        let tokens = terminating(manyDelimited(coalesce(
            bareWord.map(SchemeToken.BareWord),
            stringLiteral.map(SchemeToken.StringLiteral),
            floatingPointLiteral.map(SchemeToken.FloatingPointLiteral),
            integerLiteral.map(SchemeToken.IntegerLiteral),
            symbol.map(SchemeToken.Symbol)
        ), delimiter: many(coalesce(whitespace, comment))))
        
        do {
            let result = try tokens.parse("((hello (+5 * -3  /* this is a /* nested */ comment */ ) 5   \"world\" -43.56  )4  whoa)")
            XCTAssertEqual(15, result.count)
        } catch let error {
            XCTFail(String(error))
        }
    }
}

