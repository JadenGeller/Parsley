//
//  Infix.swift
//  Parsley
//
//  Created by Jaden Geller on 2/22/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public enum Associativity {
    case Left
    case Right
    case None
}

public protocol InfixOperatorType: Matchable {
    var precedence: Int { get }
    var associativity: Associativity { get }
}

//public struct InfixOperator<Token> {
//    public let symbol: [Token]
//    public let precedence: Int
//    public let associativity: Associativity
//    
//    public init<S: SequenceType where S.Generator.Element == Token>(symbol: S, precedence: Int, associativity: Associativity) {
//        self.symbol = Array(symbol)
//        self.precedence = precedence
//        self.associativity = associativity
//    }
//}

public enum Infix<InfixOperator: InfixOperatorType, Result> {
    indirect case Expression(infixOperator: InfixOperator, left: Infix, right: Infix)
    case Value(Result)
}

extension Associativity: Hashable {
    public var hashValue: Int {
        switch self {
        case .Left:  return -1
        case .Right: return 1
        case .None:  return 0
        }
    }
}
public func ==(lhs: Associativity, rhs: Associativity) -> Bool {
    switch (lhs, rhs) {
    case (.Left, .Left):   return true
    case (.Right, .Right): return true
    case (.None, .None):   return true
    default: return false
    }
}
// f z * (expr - f x) + expr

extension SequenceType {
    func group(@noescape isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> [[Generator.Element]] {
        var grouped: [[Generator.Element]] = []
        var similiar: [Generator.Element] = []
        for element in sort(isOrderedBefore) {
            guard !similiar.isEmpty else {
                similiar.append(element)
                continue
            }
            let check = similiar.first!
            if isOrderedBefore(element, check) || isOrderedBefore(check, element) { // Different
                grouped.append(similiar)
                similiar = [element]
            } else { // Equal
                grouped[grouped.endIndex - 1].append(element)
            }
        }
        grouped.append(similiar)
        return grouped
    }
}

extension SequenceType where Generator.Element: Comparable {
    func group() -> [[Generator.Element]] {
        return group(<)
    }
}

extension SequenceType {
    public func groupBy<Group: Hashable>(group: Generator.Element -> Group) -> [Group : [Generator.Element]] {
        var result: [Group : [Generator.Element]] = [:]
        forEach { element in
            result[group(element)] = (result[group(element)] ?? []) + [element]
        }
        return result
    }
}

@available(*, deprecated=1.0)
public func infix<InfixOperator: InfixOperatorType, Result, Discard>(operatorList: [InfixOperator], between parser: Parser<InfixOperator.TokenInput, Result>, groupedBy: (left: Parser<InfixOperator.TokenInput, Discard>, right: Parser<InfixOperator.TokenInput, Discard>)) -> Parser<InfixOperator.TokenInput, Infix<InfixOperator, Result>> {
    return infix(operatorList, operatorMatcherBuilder: { $0.matcher }, between: parser, groupedBy: groupedBy)
}

public func infix<TokenInput, InfixOperator: InfixOperatorType, Result, Discard>(operatorList: [InfixOperator], operatorMatcherBuilder: InfixOperator -> Parser<TokenInput, ()>, between parser: Parser<TokenInput, Result>, groupedBy: (left: Parser<TokenInput, Discard>, right: Parser<TokenInput, Discard>)) -> Parser<TokenInput, Infix<InfixOperator, Result>> {
    typealias InfixParser = Parser<TokenInput, Infix<InfixOperator, Result>>
    
    // Order the operators by precedence, grouping those of similiar precedence, and then further grouping by associativity.
    let precedenceSortedOperators = operatorList.group{ $0.precedence > $1.precedence }.map{ $0.groupBy { $0.associativity } }
    
    // Set the base case to `parser`.
    var level: InfixParser = between(groupedBy.left, groupedBy.right, parse:
        hold(infix(operatorList, operatorMatcherBuilder: operatorMatcherBuilder, between: parser, groupedBy: groupedBy))
        ) ?? parser.map(Infix.Value)
    
    // Iterate over the precedence levels in increasing order.
    for precedenceLevel in precedenceSortedOperators {
        let previousLevel = level // Want to capture the value before it changes.
        
        // Define how this level is parsed, updating the `previousLevel` variable for the subsequent iteration.
        // Parse operators of just one of the possible associativities.
        level = coalesce(precedenceLevel.map { (associativity: Associativity, compatibleOperators: [InfixOperator]) in
            recursive { (level: InfixParser) in
                
                // Parse any of the possible operators with this associativity and precedence.
                return coalesce(compatibleOperators.map { anOperator in
                    
                    // Parse the operator symbol expression. Each expression will be either the same or
                    // previous level depending on the associativity of the operator. Eventually, we'll
                    // run out of operators to parse and parse the previous level regardless.
                    return infix(operatorMatcherBuilder(anOperator), between:
                        associativity == .Right ? (level ?? previousLevel) : previousLevel,
                        associativity == .Left  ? (level ?? previousLevel) : previousLevel
                        ).map { lhs, rhs in
                            Infix.Expression(infixOperator: anOperator, left: lhs, right: rhs)
                    }
                    })
            }
            }) ?? previousLevel // There are no operators to parse at this level, so parse the previous level.
    }
    
    // Return the parser that will parse a tree of operators.
    return level
}

