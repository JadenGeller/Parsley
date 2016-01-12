//
//  Base.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that consumes no input and returns `value`.

    - Parameter value: The value to return on parse.
*/
@warn_unused_result public func pure<Token, Result>(value: Result) -> Parser<Token, Result> {
    return Parser { _ in
        return value
    }
}

/** 
    Constructs a `Parser` that consumes no input and returns nothing.
*/
@warn_unused_result public func none<Token>() -> Parser<Token, ()> {
    return pure(())
}

/**
    Constructs a `Parser` that consumes a single token and returns it.
*/
@warn_unused_result public func any<Token>() -> Parser<Token, Token> {
    return Parser { state in
        return try state.read()
    }
}

/**
    Constructs a `Parser` that succeeds if the input is empty. This parser
    consumes no input and returns nothing.
*/
@warn_unused_result public func end<Token>() -> Parser<Token, ()> {
    return Parser { state in
        do {
            try state.read()
            throw ParseError.UnableToMatch("endOfSequence")
        } catch let error as ParseError {
            guard case .EndOfSequence = error else { throw error }
        }
    }
}

/**
    Constructs a `Parser` that will run `parser` and ensure that no input remains upon `parser`'s completion.
    If any input does remain, an error is thrown.
 
    - Parameter parser: The parser to be run.
*/
public func terminating<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return parser.flatMap { result in end().replace(result) }
}

/**
    Constructs a `Parser` that consumes a single token and returns the token
    if it satisfies `condition`; otherwise, it throws a `ParseError`.
 
    - Parameter condition: The condition that the token must satisfy.
*/
@warn_unused_result public func satisfy<Token>(condition: Token -> Bool) -> Parser<Token, Token> {
    return any().require(condition).withError("satisfy")
}

/**
    Constructs a `Parser` that consumes a single token and returns the token
    if it is equal to the argument `token`.
 
    - Parameter token: The token that the input is tested against.
*/
@warn_unused_result public func token<Token: Equatable>(token: Token) -> Parser<Token, Token> {
    return satisfy{ $0 == token }.withError("token(\(token))")
}

/**
    Constructs a `Parser` that consumes a single token and returns the token
    if it is within the interval `interval`.
 
    - Parameter interval: The interval that the input is tested against.
 */
@warn_unused_result public func within<I: IntervalType>(interval: I) -> Parser<I.Bound, I.Bound> {
    return satisfy(interval.contains).withError("within(\(interval))")
}

/**
    Constructs a `Parser` that consumes a single token and returns the token
    if it is within the sequence `sequence`.
 
    - Parameter sequence: The sequence that the input is tested against.
 */
@warn_unused_result public func oneOf<S: SequenceType where S.Generator.Element: Equatable>(sequence: S) -> Parser<S.Generator.Element, S.Generator.Element> {
    return satisfy(sequence.contains).withError("within(\(sequence)")
}

/**
    Constructs a `Parser` that consumes a single token and returns the token
    if it is within the list `tokens`.
 
    - Parameter tokens: The list that the input is tested against.
*/
@warn_unused_result public func oneOf<Token: Equatable>(tokens: Token...) -> Parser<Token, Token> {
    return oneOf(tokens)
}

