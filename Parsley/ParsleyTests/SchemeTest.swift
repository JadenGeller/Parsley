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
    case IntegerLiteral(Int)
    case FloatingPointLiteral(Float)
    case StringLiteral(String)
    case Symbol(Character)
}

class SchemeTest: XCTestCase {

    func testScheme() {
        let whitespace = many1(within(Character(" "), "\n")).discard()
        let bareWord = sequence(letter(), many1(anyOf(letter(), digit()))).map { String($0) }
        let integerLiteral = sequence(optional(within("+", "-")), many1(digit())).map { sign, digits in String(sign) ?? "" + String(digits) }
        let floatingPointLiteral = sequence(integerLiteral, character("."), many(digit())).map { integer, _, float in String(integer) + "." + String(float) }
        let stringLiteral = sequence(token("\""), until(token("\"")), token("\"")).map { _, s, _ in s }
        let symbol = within("()+-*/".characters)
        
        let tokenizer = tokenize([bareWord.map(SchemeToken.BareWord).map(Optional.Some), integerLiteral.map{ (x: String) in 0 }.map(SchemeToken.IntegerLiteral), floatingPointLiteral.map { 100 }.map(SchemeToken.FloatingPointLiteral), stringLiteral.map(SchemeToken.StringLiteral), symbol.map(SchemeToken.Symbol)], ignoring: [whitespace.discard()])
    }

}

