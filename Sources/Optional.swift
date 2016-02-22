//
//  Optional.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

extension Parser {
    /**
        Constructs a `Parser` that catches an error and returns `recovery` instead.
    
        - Parameter recovery: Result to be returned in case of an error.
    */
    @warn_unused_result public func otherwise(recovery: Result) -> Parser {
        return attempt(self).recover { _ in pure(recovery) }
    }
}

/**
    Constructs a `Parser` that will attempt to parse with `parser`, but will backtrack and return `nil` on failure

    - Parameter parser: The parser to run.
*/
@warn_unused_result public func optional<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result?> {
    return parser.map(Optional.Some).otherwise(nil)
}

/**
Constructs a `Parser` that will attempt to parse with `parser`, but will backtrack and return `nil` on failure

- Parameter parser: The parser to run.
*/
@warn_unused_result public func optional<Token, Result>(parser: Parser<Token, [Result]>) -> Parser<Token, [Result]> {
    return parser.otherwise([])
}

/**
    Constructs a `Parser` that will attempt to parse with `parser`, but will backtrack and return `otherwise` on failure

    - Parameter parser: The parser to run.
    - Parameter otherwise: The default value to return on failure.
*/
@warn_unused_result public func optional<Token, Result>(parser: Parser<Token, Result>, otherwise: Result) -> Parser<Token, Result> {
    return parser.otherwise(otherwise)
}

/**
    Constructs a `Parser` that will return the unwrapped result if it is not `nil`, and will fail otherwise.
*/
extension Parser where Result: OptionalType {
    @warn_unused_result public func unwrap() -> Parser<Token, Result.Element> {
        return require { $0.optionalValue != nil }.map { $0.optionalValue! }
    }
}

// MARK: Helpers

public protocol OptionalType {
    typealias Element
    var optionalValue: Optional<Element> { get }
}

extension Optional: OptionalType {
    public var optionalValue: Optional {
        return self
    }
}