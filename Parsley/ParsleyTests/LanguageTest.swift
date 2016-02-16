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

enum Sign: Character, TokenSet {
    case Negative = "-"
    case Positive = "+"
    
    static var all: [Sign] = [.Negative, .Positive]
    var matcher: Parser<Character, ()> {
        return character(rawValue).discard()
    }
}

enum Operator: String, TokenSet, Equatable, CustomStringConvertible {
    case Assignment = ":="
    case Lambda = "->"
    case Binding = "::"
    
    static var all: [Operator] = [.Assignment, .Lambda, .Binding]
    
    var matcher: Parser<Character, ()> {
        return string(rawValue).discard()
    }
    
    var description: String {
        return rawValue
    }
}

func ==(lhs: Operator, rhs: Operator) -> Bool {
    switch (lhs, rhs) {
    case (.Assignment, .Assignment): return true
    case (.Lambda, .Lambda): return true
    case (.Binding, .Binding): return true
    default:
        return false
    }
}

enum ControlFlow: TokenSet, CustomStringConvertible {
    case Nested(PairedDelimiter)
    case Terminator
    case Infix(Operator)
    
    static let terminatorCharacter: Character = ";"
    
    static var all = PairedDelimiter.all.map(ControlFlow.Nested) + [.Terminator] + Operator.all.map(ControlFlow.Infix)
    
    var matcher: Parser<Character, ()> {
        switch self {
        case .Nested(let pairedDelimiter): return pairedDelimiter.matcher
        case .Terminator:                  return character(ControlFlow.terminatorCharacter).discard()
        case .Infix(let infixOperator):    return infixOperator.matcher
        }
    }
    
    var description: String {
        switch self {
        case .Nested(let pairedDelimiter): return pairedDelimiter.description
        case .Terminator: return String(ControlFlow.terminatorCharacter)
        case .Infix(let infixOperator): return infixOperator.description
        }
    }
}

enum Token: Tokenizable, CustomStringConvertible {
    case Bare(String)
    case Literal(LiteralValue)
    case Flow(ControlFlow)
    
    private static let bareWord = prepend(
        letter ?? character("_"),
        many(letter ?? digit ?? character("_"))
    ).stringify().withError("bareWord")
    
    static var tokenizer = LiteralValue.tokenizer.map(Token.Literal) ?? ControlFlow.tokenizer.map(Token.Flow) ?? bareWord.map(Token.Bare)
    
    var description: String {
        switch self {
        case .Bare(let value): return value
        case .Literal(let value): return "\(value)"
        case .Flow(let value): return value.description
        }
    }
}

struct PairedDelimiter: Equatable, TokenSet, CustomStringConvertible {
    enum Symbol: Equatable {
        case Parenthesis
        case CurlyBracket
        
        static var all: [Symbol] = [.Parenthesis, .CurlyBracket]
    }
    enum Facing: Equatable {
        case Open
        case Close
        
        static var all: [Facing] = [.Open, .Close]
    }
    
    let symbol: Symbol
    let facing: Facing
    
    var characterValue: Character {
        switch symbol {
        case .Parenthesis:
            switch facing {
            case .Open:  return "("
            case .Close: return ")"
            }
        case .CurlyBracket:
            switch facing {
            case .Open:  return "{"
            case .Close: return "}"
            }
        }
    }
    
    static var all = Symbol.all.flatMap{ symbol in
        Facing.all.map{ facing in
            return PairedDelimiter(symbol: symbol, facing: facing)
        }
    }
    
    var matcher: Parser<Character, ()> {
        return character(characterValue).discard()
    }
    
    var description: String {
        return String(characterValue)
    }
}

func ==(lhs: PairedDelimiter.Symbol, rhs: PairedDelimiter.Symbol) -> Bool {
    switch (lhs, rhs) {
    case (.Parenthesis, .Parenthesis): return true
    case (.CurlyBracket, .CurlyBracket): return true
    default: return false
    }
}

func ==(lhs: PairedDelimiter.Facing, rhs: PairedDelimiter.Facing) -> Bool {
    switch (lhs, rhs) {
    case (.Open, .Open): return true
    case (.Close, .Close): return true
    default: return false
    }
}

func ==(lhs: PairedDelimiter, rhs: PairedDelimiter) -> Bool {
    return lhs.facing == rhs.facing && lhs.symbol == rhs.symbol
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

enum LiteralValue: Tokenizable, Equatable {
    case IntegerLiteral(sign: Sign, digits: DigitList)
    case FloatingPointLiteral(sign: Sign, significand: DigitList, exponent: Int)
    case StringLiteral(String)
    
    private static let sign = Sign.tokenizer.otherwise(.Positive)
    
    private static let digits = many1(digit)
        .stringify()
        .map(DigitList.init).map{ $0! }
    
    private static let integerLiteral = pair(sign, digits)
        .map(LiteralValue.IntegerLiteral)
        .withError("integerLiteral")
    
    private static let floatingPointLiteral = Parser<Character, LiteralValue> { state in
        let theSign = try sign.parse(state)
        let leftDigits = try digits.parse(state)
        let decimal = try character(".").parse(state)
        let rightDigits = try digits.parse(state)
        return .FloatingPointLiteral(sign: theSign, significand: leftDigits + rightDigits, exponent: -rightDigits.digits.count)
    }
    
    private static let stringLiteral = between(character("\""), parseFew: string("\\\"") ?? any().lift())
        .map { $0.flatten() }
        .stringify()
        .map(LiteralValue.StringLiteral)

    static var tokenizer = floatingPointLiteral ?? integerLiteral ?? stringLiteral
}

func ==(lhs: LiteralValue, rhs: LiteralValue) -> Bool {
    switch (lhs, rhs) {
    case let (.IntegerLiteral(l), .IntegerLiteral(r)):
        return l.sign == r.sign && l.digits == r.digits
    case let (.FloatingPointLiteral(l), .FloatingPointLiteral(r)):
        return l.sign == r.sign && l.significand == r.significand && l.exponent == r.exponent
    case let (.StringLiteral(l), .StringLiteral(r)):
        return l == r
    default:
        return false
    }
}

enum Digit: Int, Equatable {
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

func ==(lhs: Digit, rhs: Digit) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

struct DigitList: SequenceType, Equatable {
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

func ==(lhs: DigitList, rhs: DigitList) -> Bool {
    return lhs.digits == rhs.digits
}

class LanguageTest: XCTestCase {
    func testDelimiter() {
        XCTAssertEqual(PairedDelimiter(symbol: .CurlyBracket, facing: .Open), try? PairedDelimiter.tokenizer.parse("{".characters))
    }
    
    func testLiteral() {
        XCTAssertEqual(
            LiteralValue.IntegerLiteral(sign: .Positive, digits: DigitList(string: "5232")!),
            try? LiteralValue.tokenizer.parse("+5232")
        )
        XCTAssertEqual(
            LiteralValue.IntegerLiteral(sign: .Positive, digits: DigitList(string: "085328235")!),
            try? LiteralValue.tokenizer.parse("085328235")
        )
        XCTAssertEqual(
            LiteralValue.FloatingPointLiteral(sign: .Negative, significand: DigitList(string: "583253218")!, exponent: -5),
            try? LiteralValue.tokenizer.parse("-5832.53218")
        )
        XCTAssertEqual(
            LiteralValue.StringLiteral("Hello \\\"world\\\""),
            try? LiteralValue.tokenizer.parse("\"Hello \\\"world\\\"\"")
        )
    }
    
    func testOperator() {
        XCTAssertEqual(
            Operator.Assignment,
            try? Operator.tokenizer.parse(":=")
        )
        XCTAssertEqual(
            Operator.Lambda,
            try? Operator.tokenizer.parse("->")
        )
        XCTAssertEqual(
            Operator.Binding,
            try? Operator.tokenizer.parse("::")
        )
    }
    
    func testTokenize() {
        print(try? tokens(Token.self, optionallyDelimitedBy: whitespace).parse("factorial := (x :: Int) ->  {\n    mutable x := x\n    mutable result := 1\n    while (_ -> greater x 0) (_ -> set result (multiply result x))\n    result\n} :: Int"))
    }
}
