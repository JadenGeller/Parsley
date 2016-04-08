//
//  OperatorProperties.swift
//  Parsley
//
//  Created by Jaden Geller on 4/8/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public enum OperatorProperties {
    case infix(precedence: Int, associativity: Associativity)
    case prefix
    case postfix
}

extension OperatorProperties {
    public var precedence: Int {
        switch self {
        case .infix(let precedence, _):
            return precedence
        default:
            return Int.max
        }
    }
    
    public var associativity: Associativity {
        switch self {
        case .infix(_, let associativity):
            return associativity
        default:
            return .none
        }
    }
}

extension OperatorProperties: Equatable { }
public func ==(lhs: OperatorProperties, rhs: OperatorProperties) -> Bool {
    switch (lhs, rhs) {
    case (.infix(let lPrecedence, let lAssociativity), .infix(let rPrecedence, let rAssociativity)):
        return lPrecedence == rPrecedence && lAssociativity == rAssociativity
    case (.prefix, .prefix):
        return true
    case (.postfix, .postfix):
        return true
    default:
        return false
    }
}

extension OperatorProperties: Hashable {
    public var hashValue: Int {
        switch self {
        case .infix(let precedence, let associativity):
            return ((precedence.hashValue << 1) ^ (associativity.hashValue)) << 1
        case .prefix:
            return 0
        case .postfix:
            return 1
        }
    }
}
