//
//  OperatorTests.swift
//  Parsley
//
//  Created by Jaden Geller on 2/22/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Parsley

private enum Precedence {
    case Low
    case Medium
    case High
}

private enum Associativity {
    case Left
    case Right
    case None
}

private enum Expression {
    case Number(Int)
    indirect case Add(Expression, Expression)
    indirect case Subtract(Expression, Expression)
    indirect case Multiply(Expression, Expression)
    indirect case Divide(Expression, Expression)
    indirect case Exponent(Expression, Expression)
}

extension Expression: Parsable {
//    static var
//    static var tokenParser = either(
//        numberParser,
//        between(character("("), character(")"), parse: expressionParser)
//    )
    
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
        let input = "1+2*3*(2+6)*4^3+2*8/9"
        print(try! terminating(Expression.parser).parse(input))
    }
}