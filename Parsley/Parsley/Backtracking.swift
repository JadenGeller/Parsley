//
//  Backtracking.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that runs attempts to run `parser` and backtracks on failure.
    On successful parse, this parser returns the result of `parse`; on failure, this parser
    catches the error, rewinds the `ParseState` back to the state before the parse, and
    rethrows the error.

    - Parameter attempt: The parser to run.
*/
public func attempt<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { state in
        let snapshot = state.snapshot()
        do {
            return try parser.parse(state)
        }
        catch let error as ParseError {
            state.rewind(toSnapshot: snapshot)
            throw error
        }
    }
}

/**
    Constructs a `Parser` that runs `parser` without actually consuming any input.

    - Parameter parser: The parser to run.
*/
public func lookahead<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { state in
        let snapshot = state.snapshot()
        defer { state.rewind(toSnapshot: snapshot) }
        return try parser.parse(state)
    }
}

/**
    Constructs a `Parser` that will parse with `rightParser` whenever `leftParser` fails.

    - Parameter leftParser: The parser to run first.
    - Parameter rightParser: The parser to run whenever the first parser fails.
*/
public func either<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, Either<LeftResult, RightResult>> {
    return Parser { state in
        do {
            return .Left(try attempt(leftParser).parse(state))
        } catch let leftError as ParseError {
            do {
                return .Right(try rightParser.parse(state))
            } catch let rightError as ParseError {
                throw ParseError("either(\(leftError), \(rightError))")
            }
        }
    }
}

/**
    Constructs a `Parser` that will parse with the first element of `parsers` that succeeds.

    - Parameter parsers: The sequence of parsers to attempt.
*/
public func anyOf<Token, Result, Sequence: SequenceType where Sequence.Generator.Element == Parser<Token, Result>>
    (parsers: Sequence) -> Parser<Token, Result> {
        return Parser { state in
            var errors = [ParseError]()
            for parser in parsers {
                do {
                    return try attempt(parser).parse(state)
                } catch let error as ParseError {
                    errors.append(error)
                }
            }
            let message = errors.reduce("") { result, next in result + ", " + next.message }
            throw ParseError("anyOf(\(message))")
        }
}

/**
    Constructs a `Parser` that will parse with the first element of `parsers` that succeeds.

    - Parameter parsers: A variadic list of parsers to attempt.
*/
public func anyOf<Token, Result>(parsers: (Parser<Token, Result>)...) -> Parser<Token, Result> {
    return anyOf(parsers)
}

/**
    Constructs a `Parser` that will attempt to parse with `parser`, but will backtrack and return `nil` on failure

    - Parameter parser: The parser to run.
*/
public func optional<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result?> {
    return anyOf(parser.map(Optional.Some), pure(Optional.None))
}

/**
    Constructs a `Parser` that will attempt to parse with `parser`, but will backtrack and return `otherwise` on failure

    - Parameter parser: The parser to run.
    - Parameter attempt: The default value to return on failure.
*/
public func optional<Token, Result>(parser: Parser<Token, Result>, otherwise: Result) -> Parser<Token, Result> {
    return parser.otherwise(otherwise)
}

// MARK: Helpers

/**
    A datatype that represents can manifest itself as one of two types.
*/
public enum Either<A, B> {
    case Left(A)
    case Right(B)
}

