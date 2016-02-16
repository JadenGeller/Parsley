//
//  LanguageTest.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Foundation
import XCTest
import Parsley

enum Sign {
    case Negative
    case Positive
}

extension Sign {
    init?(character: Character) {
        switch character {
        case "-":
            self = .Negative
        case "+":
            self = .Positive
        default:
            return nil
        }
    }
}

enum LiteralValue {
    case IntegerLiteral(sign: Sign, digits: DigitList)
    case FloatingPointLiteral(sign: Sign, significand: DigitList, exponent: Int)
    case StringLiteral(String)
}

enum Digit: Int {
    case Zero
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
    case Seven
    case Eight
    case Nine
}

struct DigitList: SequenceType {
    let digits: [Digit]
    
    init(digits: [Digit]) {
        self.digits = digits
    }
    
    init?(string: String) {
        struct Exception: ErrorType { }
        do {
            self.digits = try string.characters.map { c in
                guard let v = Int(String(c)) else { throw Exception() }
                guard let d = Digit(rawValue: v) else { throw Exception() }
                return d
            }
        } catch {
            return nil
        }
    }
    
    func generate() -> IndexingGenerator<[Digit]> {
        return digits.generate()
    }
}

func +(lhs: DigitList, rhs: DigitList) -> DigitList {
    return DigitList(digits: lhs.digits + rhs.digits)
}

struct Language {
    static let bareWord = prepend(
        letter ?? character("_"),
        many1(letter ?? digit ?? character("_"))
    ).withError("bareWord")
    
    static let sign = optional(within("+-")).map{ $0.flatMap(Sign.init) ?? .Positive }
    
    static let digits = many1(digit).stringify().map(DigitList.init).map{ $0! }
    
    static let integerLiteral = pair(sign, digits).map(LiteralValue.IntegerLiteral).withError("integerLiteral")
    
    static let floatingPointLiteral = Parser<Character, LiteralValue> { state in
        let theSign = try sign.parse(state)
        let leftDigits = try digits.parse(state)
        let decimal = try character(".").parse(state)
        let rightDigits = try digits.parse(state)
        return .FloatingPointLiteral(sign: theSign, significand: leftDigits + rightDigits, exponent: -rightDigits.digits.count)
    }

    //let stringLiteral = sequence(
    //    character("\"").lift().discard(),
    //    many(any(), then: character("\"").discard()).map{ (l, r) in l }
    //).map{ (l, r) in r }.withError("stringLiteral")

}

class LanguageTest: XCTestCase {
    func testTest() {
        
    }
}