//
//  OperatorExpression.swift
//  Parsley
//
//  Created by Jaden Geller on 2/22/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public enum OperatorExpression<Symbol, Element> {
    case value(Element)
    indirect case infix(infixOperator: Symbol, between: (OperatorExpression, OperatorExpression))
//    indirect case prefix(prefixOperator: Symbol, before: OperatorExpression)
//    indirect case postfix(postfixOperator: Symbol, after: OperatorExpression)
}

//extension Infix: Equatable where Symbol: Equatable, Element: Equatable { }
public func ==<Symbol: Equatable, Element: Equatable>(lhs: OperatorExpression<Symbol, Element>, rhs: OperatorExpression<Symbol, Element>) -> Bool {
    switch (lhs, rhs) {
    case (.value(let l), .value(let r)):
        return l == r
    case (.infix(let lInfixOperator, let lBetween), .infix(let rInfixOperator, let rBetween)):
        return lInfixOperator == rInfixOperator && lBetween.0 == rBetween.0 && lBetween.1 == rBetween.1
    default:
        return false
    }
}

extension OperatorExpression: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .value(let element):
            return "\(element)"
        case .infix(let infixOperator, let (left, right)):
            return "(\(left) \(infixOperator) \(right))"
//        case .prefix(let prefixOperator , let value):
//            return "(\(prefixOperator) \(value))"
//        case .postfix(let postfixOperator , let value):
//            return "(\(value) \(postfixOperator))"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .value(let element):
            return "OperatorExpression.value(\(element))"
        case .infix(let infixOperator, let (left, right)):
            return "OperatorExpression.infix(infixOperator: \(infixOperator), between: (\(left), \(right)))"
//        case .prefix(let prefixOperator , let value):
//            return "OperatorExpression.prefix(prefixOperator: \(prefixOperator), before: \(value))"
//        case .postfix(let postfixOperator , let value):
//            return "OperatorExpression.postfix(postfixOperator: \(postfixOperator), after: \(value))"
        }
    }
}

public func operatorExpression<Symbol: Hashable, Token, Result, Discard>(
        parsing parser: Parser<Token, Result>,
        groupedBy grouping: (left: Parser<Token, Discard>, right: Parser<Token, Discard>),
        usingSpecification specification: OperatorSpecification<Symbol>,
        matching: Symbol -> Parser<Token, Result>
    ) -> Parser<Token, OperatorExpression<Symbol, Result>> {
    typealias OperatorParser = Parser<Token, OperatorExpression<Symbol, Result>>
    
    // This is the bottom layer of the parser. We will place layer upon layer on top of this so we'll
    // first check for low precedence paths (like addition) before we check high precedence paths
    // (like multiplication). If this seems opposite to your intuitions, think of it this way: If we
    // first find the addition, then it will be more loosely bound than the later found multiplication.
    // For example, given (3 * 2 + 5), finding addition first gives us ((3 * 2) + (5)).
    var level = between(grouping.left, grouping.right, parse: hold(operatorExpression(
        parsing: parser,
        groupedBy: grouping,
        usingSpecification: specification,
        matching: matching
    ))) ?? parser.map(OperatorExpression.value)

    // Iterate over the precedence levels in decreasing order since we're building this parser from the bottom up.
    for precedenceLevel in specification.descendingPrecedenceTieredInfixDeclarations {
        let previousLevel = level // Want to capture the value before it changes.

        // Define how this level is parsed, updating the `previousLevel` variable for the subsequent iteration.
        // Parse operators of just one of the possible associativities.
        level = coalesce(precedenceLevel.map { (associativity: Associativity, compatibleOperators: [Symbol]) in
            recursive { (currentLevel: OperatorParser) in
                
                // Parse any of the possible operators with this associativity and precedence.
                return coalesce(compatibleOperators.map { infixOperator in
                
                    // Parse the operator symbol expression. Each expression will be either the same or
                    // previous level depending on the associativity of the operator. Eventually, we'll
                    // run out of operators to parse and parse the previous level regardless.
                    return infix(matching(infixOperator), between:
                        associativity == .right ? (currentLevel ?? previousLevel) : previousLevel,
                        associativity == .left  ? (currentLevel ?? previousLevel) : previousLevel
                    ).map { lhs, rhs in
                        OperatorExpression.infix(infixOperator: infixOperator, between: (lhs, rhs))
                    }
                })
            }
        }) ?? previousLevel // There are no operators to parse at this level, so parse the previous level.
    }
    
//    // Handle prefix and postfix operators
//    let x = specification.prefixOperators.map { prefixOperator in
//        pair(matching(prefixOperator), level).map(right)
//            OperatorExpression.prefix(prefixOperator:
//        }
//    }
    
    // Return the parser that will parse a tree of operators.
    return level
}

