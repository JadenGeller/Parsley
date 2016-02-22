//
//  OperatorTests.swift
//  Parsley
//
//  Created by Jaden Geller on 2/22/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Parsley

private enum Expression {
    case Number(Int)
    indirect case Add(Expression, Expression)
    indirect case Subtract(Expression, Expression)
    indirect case Multiply(Expression, Expression)
    indirect case Divide(Expression, Expression)
    indirect case Exponent(Expression, Expression)
}

private enum InfixOperator: String, InfixOperatorType {
    case Plus = "+"
    case Minus = "-"
    case Times = "*"
    case Slash = "/"
    case Power = "^"
    
    // Unnecessary except for by the protocol :P lame
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

private func toExpression(infix: Infix<InfixOperator, Int>) -> Expression {
    switch infix {
    case let .Expression(.Plus, left, right):
        return .Add(toExpression(left), toExpression(right))
    case let .Expression(.Minus, left, right):
        return .Subtract(toExpression(left), toExpression(right))
    case let .Expression(.Times, left, right):
        return .Multiply(toExpression(left), toExpression(right))
    case let .Expression(.Slash, left, right):
        return .Divide(toExpression(left), toExpression(right))
    case let .Expression(.Power, left, right):
        return .Exponent(toExpression(left), toExpression(right))
    case let .Value(value):
        return .Number(value)
    }
}

extension Expression: Parsable {
//    static var
//    static var tokenParser = either(
//        numberParser,
//        between(character("("), character(")"), parse: expressionParser)
//    )
    static var parser = infix(InfixOperator.self, between: many1(digit).map{ Int(String($0))! }).map(toExpression)
    
    #if false
    static var parser = recursive { (expression: Parser<Character, Expression>) in
        let token = (recursive { (token: Parser<Character, Expression>) in
            let number = many1(digit).map{ Expression.Number(Int(String($0))!) }.debug("number")
            return coalesce(
                number,
                between(character("(").debug("open paren"), character(")").debug("close paren"), parse: expression.debug("paren expr"))
            )
        }).debug("token")
        
        let high = recursive { (high: Parser<Character, Expression>) in
            (infix(character("^").debug("high ^"), between: token.debug("high lhs"), high.debug("high rhs")) { _ in
                Expression.Exponent
            } ?? token.debug("high otherwise")).debug("high")
        }
        
        let medium = recursive { (medium: Parser<Character, Expression>) in
            (infix(within("*/").debug("medium */"), between: high.debug("medium lhs"), medium.debug("medium rhs")) { c in
                switch c {
                case "*": return Expression.Multiply
                case "/": return Expression.Divide
                default: fatalError()
                }
            } ?? high.debug("medium otherwise")).debug("medium")
        }
        
        let low = recursive { (low: Parser<Character, Expression>) in
            (infix(within("+-").debug("low +-"), between: medium.debug("low lhs"), low.debug("low rhs")) { c in
                switch c {
                case "+": return Expression.Add
                case "-": return Expression.Subtract
                default: fatalError()
                }
            } ?? medium.debug("low otherwise")).debug("low")
        }

        return low
    }
    #endif
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
        let input = "1+2"
        print(try! terminating(Expression.parser).parse(input))
    }
}