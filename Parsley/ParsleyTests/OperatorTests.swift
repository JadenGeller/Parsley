//
//  OperatorTests.swift
//  Parsley
//
//  Created by Jaden Geller on 2/22/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Parsley

private enum Expression: Equatable {
    case Number(Int)
    indirect case Add(Expression, Expression)
    indirect case Subtract(Expression, Expression)
    indirect case Multiply(Expression, Expression)
    indirect case Divide(Expression, Expression)
    indirect case Exponent(Expression, Expression)
}

extension Expression: IntegerLiteralConvertible {
    init(integerLiteral value: Int) {
        self = .Number(value)
    }
}

private func ==(lhs: (Expression, Expression), rhs: (Expression, Expression)) -> Bool {
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

private func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case let (.Number(l), .Number(r)):     return l == r
    case let (.Add(l), .Add(r)):           return l == r
    case let (.Subtract(l), .Subtract(r)): return l == r
    case let (.Multiply(l), .Multiply(r)): return l == r
    case let (.Divide(l), .Divide(r)):     return l == r
    case let (.Exponent(l), .Exponent(r)): return l == r
    default: return false
    }
}

private enum InfixOperator: String, InfixOperatorType {
    case Plus = "+"
    case Minus = "-"
    case Times = "*"
    case Slash = "/"
    case Power = "^"
    
    static var all: [InfixOperator] = [.Plus, .Minus, .Times, .Slash, .Power]
    
    var matcher: Parser<Character, ()> {
        return string(rawValue).discard()
    }
    
    var associativity: Associativity {
        return .Left
    }
    
    var precedence: Int {
        switch self {
        case .Plus:  return 10
        case .Minus: return 10
        case .Times: return 20
        case .Slash: return 20
        case .Power: return 30
        }
    }
}

extension Expression: Parsable {
    static func build(infix: Infix<InfixOperator, Int>) -> Expression {
        switch infix {
        case let .Expression(op, left, right):
            return Expression.initializer(op)(build(left), build(right))
        case let .Value(value):
            return .Number(value)
        }
    }
    
    static func initializer(op: InfixOperator) -> (Expression, Expression) -> Expression {
        switch op {
        case .Plus:  return Expression.Add
        case .Minus: return Expression.Subtract
        case .Times: return Expression.Multiply
        case .Slash: return Expression.Divide
        case .Power: return Expression.Exponent
        }
    }
    
    static var parser = infix(InfixOperator.self,
        between: many1(digit).map{ Int(String($0))! },
        groupedBy: (character("("), character(")"))
    ).map(Expression.build)
}

extension Expression: CustomStringConvertible {
    var description: String {
        switch self {
        case let .Number(value): return value.description
        case let .Add(lhs, rhs): return "(" + lhs.description + "+" + rhs.description + ")"
        case let .Subtract(lhs, rhs): return "(" + lhs.description + "-" + rhs.description + ")"
        case let .Multiply(lhs, rhs): return "(" + lhs.description + "*" + rhs.description + ")"
        case let .Divide(lhs, rhs): return "(" + lhs.description + "/" + rhs.description + ")"
        case let .Exponent(lhs, rhs): return "(" + lhs.description + "^" + rhs.description + ")"
        }
    }
}

class OperatorTest: XCTestCase {
    func testOperator() {
        XCTAssertEqual(
            .Add(1, .Add(.Multiply(.Exponent(3, 2), .Divide(.Add(5, 4), 8)), .Multiply(3, 3))),
            Expression.parse("1+3^2*(5+4)/8+3*3")
        )
    }
}
