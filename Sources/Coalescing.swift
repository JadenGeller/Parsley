//
//  Coalescing.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that will parse with the first parser in `parsers` that succeeds.

    - Parameter parsers: The sequence of parsers to attempt.
*/
@warn_unused_result public func coalesce<Token, Result, Sequence: SequenceType where Sequence.Generator.Element == Parser<Token, Result>>
    (parsers: Sequence) -> Parser<Token, Result> {
        return Parser { state in
            for parser in parsers {
                do {
                    return try attempt(parser).parse(state)
                }
                catch _ as ParseError { }
            }
            throw ParseError.UnableToMatch("coalesce")
        }
}

/**
    Constructs a `Parser` that will parse with the first element of `parsers` that succeeds.
 
    - Parameter parsers: A variadic list of parsers to attempt.
*/
@warn_unused_result public func coalesce<Token, Result>(parsers: (Parser<Token, Result>)...) -> Parser<Token, Result> {
    return coalesce(parsers)
}

/**
    Constructs a `Parser` that will parse with `rightParser` if and only if `leftParser` fails.
    Note that the construct parser will result in the same type as both other parsers.
 
    - Parameter leftParser: The parser to run first.
    - Parameter rightParser: The parser to run whenever the first parser fails.
*/
@warn_unused_result public func ??<Token, Result>(leftParser: Parser<Token, Result>, rightParser: Parser<Token, Result>) -> Parser<Token, Result> {
    return coalesce(leftParser, rightParser)
}

/**
    Constructs a `Parser` that will parse with `rightParser` whenever `leftParser` fails.
    Note that the two parsers need not be the same type as an `Either` type is the result.
 
    - Parameter leftParser: The parser to run first.
    - Parameter rightParser: The parser to run whenever the first parser fails.
 */
@warn_unused_result public func either<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, Either<LeftResult, RightResult>> {
    return Parser { state in
        do {
            return .Left(try attempt(leftParser).parse(state))
        } catch let leftError as ParseError {
            do {
                return .Right(try rightParser.parse(state))
            } catch let rightError as ParseError {
                throw ParseError.UnableToMatch("either(\(leftError), \(rightError)")
            }
        }
    }
}

// MARK: Helpers

/**
    A datatype that can manifest itself as one of two types.
*/
public enum Either<L, R> {
    case Left(L)
    case Right(R)
}

public func ==<L: Equatable, R: Equatable>(lhs: Either<L, R>, rhs: Either<L, R>) -> Bool {
    switch (lhs, rhs) {
    case let (.Left(l), .Left(r)):   return l == r
    case let (.Right(l), .Right(r)): return l == r
    default:                         return false
    }
}
