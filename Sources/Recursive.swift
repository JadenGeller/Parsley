//
//  Recursive.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that is able to recurse on itself.

    - Parameter recurse: A function that receives its `Parser` return value as an argument.
*/
@warn_unused_result public func recursive<Token, Result>(recurse: Parser<Token, Result> -> Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { state in
        try fixedPoint{ (implementation: ParseState<Token> throws -> Result) in
            return recurse(Parser(implementation)).implementation
        }(state)
    }
}

// MARK: Helpers

/**
    A function that enables anonymous functions to recurse on themselves.

    - Parameter recurse: A function that recieves itself as an argument.
*/
@warn_unused_result private func fixedPoint<T, V>(recurse: (T throws -> V) -> (T throws -> V)) -> T throws -> V {
    return { try recurse(fixedPoint(recurse))($0) }
}

@warn_unused_result public func hold<T, V>(@autoclosure(escaping) parser: () -> Parser<T, V>) -> Parser<T, V> {
    return Parser { state in
        return try parser().parse(state)
    }
}
