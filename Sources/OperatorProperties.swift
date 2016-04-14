//
//  OperatorProperties.swift
//  Parsley
//
//  Created by Jaden Geller on 4/8/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct OperatorProperties {
    public var precedence: Int
    public var associativity: Associativity

    public init(precedence: Int, associativity: Associativity) {
        self.precedence = precedence
        self.associativity = associativity
    }
}

extension OperatorProperties: Equatable { }
public func ==(lhs: OperatorProperties, rhs: OperatorProperties) -> Bool {
    return lhs.precedence == rhs.precedence && lhs.associativity == rhs.associativity
}

extension OperatorProperties: Hashable {
    public var hashValue: Int {
        return ((precedence.hashValue << 1) ^ (associativity.hashValue)) << 1
    }
}
