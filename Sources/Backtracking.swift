//
//  Backtracking.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that runs attempts to run `parser` and backtracks on failure.
    On successful parse, this parser returns the result of `parse`; on failure, this parser
    catches the error, rewinds the `Stream` back to the state before the parse, and
    rethrows the error.

    - Parameter attempt: The parser to run with backtracking on failure.
*/
@warn_unused_result public func attempt<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
    parser
    return Parser { state in
        let checkpoint = state.checkpoint()
        do {
            return try parser.parse(state)
        }
        catch let error as ParseError {
            state.restore(checkpoint)
            throw error
        }
    }
}

@warn_unused_result public func lookahead<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { state in
        let checkpoint = state.checkpoint()
        defer { state.restore(checkpoint) }
        return try parser.parse(state)
    }
}

// TODO: This should be cleaned up to use some combinator.
@warn_unused_result public func not<Token, Ignore, Result>(failingParser: Parser<Token, Ignore>, then successfulParser: Parser<Token, Result>) -> Parser<Token, Result> {
    return Parser { state in
        let checkpoint = state.checkpoint()
        do {
            try failingParser.parse(state)
        }
        catch _ as ParseError {
            state.restore(checkpoint)
            return try successfulParser.parse(state)
        }
        throw ParseError.UnableToMatch("not") // TODO: Bad error
    }
}

@warn_unused_result public func except<Token, Ignore>(failingParser: Parser<Token, Ignore>) -> Parser<Token, Token> {
    return not(failingParser, then: any())
}