//
//  Associativity.swift
//  Parsley
//
//  Created by Jaden Geller on 4/8/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public enum Associativity {
    case left, right, none
}

extension Associativity {
    static var all: [Associativity] {
        return [.left, .right, .none]
    }
}

extension Associativity {
    public func isCompatible(with associativity: Associativity) -> Bool {
        switch (self, associativity) {
        case (.left, .left), (.right, .right):
            return true
        default:
            return false
        }
    }
}

extension Associativity: Equatable { }
public func ==(lhs: Associativity, rhs: Associativity) -> Bool {
    switch (lhs, rhs) {
    case (.left, .left), (.right, .right), (.none, .none):
        return true
    default:
        return false
    }
}

extension Associativity: Hashable {
    public var hashValue: Int {
        switch self {
        case .left:  return -1
        case .right: return 1
        case .none:  return 0
        }
    }
}

extension Associativity: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .none:
            return "none"
        }
    }
    
    public var debugDescription: String {
        return "Associativity." + description
    }
}
