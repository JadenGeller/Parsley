//
//  InfixOperator.swift
//  Parsley
//
//  Created by Jaden Geller on 4/8/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct OperatorDeclaration<Symbol: Hashable> {
    public var symbol: Symbol
    public var properties: OperatorProperties
    
    public init(symbol: Symbol, properties: OperatorProperties) {
        self.symbol = symbol
        self.properties = properties
    }
}

//extension Operator: Equatable where Symbol: Equatable { }
public func ==<Symbol: Equatable>(lhs: OperatorDeclaration<Symbol>, rhs: OperatorDeclaration<Symbol>) -> Bool {
    return lhs.symbol == rhs.symbol && lhs.properties == rhs.properties
}

// When conditional conformances exist, remove Symbol: Hashable requirement from Operator
extension OperatorDeclaration: Hashable /* where Symbol: Hashable */ {
    public var hashValue: Int {
        return (symbol.hashValue << 1) ^ (properties.hashValue)
    }
}