//
//  Utilities.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public func removeNil<Token, Result>(parser: Parser<Token, [Result?]>) -> Parser<Token, [Result]> {
    return parser.map { results in
        results.filter { $0 != nil }.map { $0! }
    }
}

/**
    Constructs a `Parser` that will run `leftParser` followed by `rightParser`, discarding the result from
    `rightParser` and returning the result from `leftParser`.

    - Parameter leftParser: The parser whose result will be propagated.
    - Parameter rightParser: The parser whose result will be discarded.
*/
public func leftResult<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, LeftResult> {
    return sequence(leftParser, rightParser).map { left, right in left }
}

/**
    Constructs a `Parser` that will run `leftParser` followed by `rightParser`, discarding the result from
    `leftParser` and returning the result from `rightParser`.

    - Parameter leftParser: The parser whose result will be discarded.
    - Parameter rightParser: The parser whose result will be propagated.
*/
public func rightResult<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, RightResult> {
    return sequence(leftParser, rightParser).map { left, right in right }
}

/**
    Constructs a `Parser` that will run `parser` and ensure that no input remains upon `parser`'s completion.
    If any input does remain, an error is thrown.

    - Parameter parser: The parser to be run.
*/
public func terminating<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return leftResult(parser, end())
}

/**
    Constructs a `Parser` that will run `parser`; if `parser` succeeds, this parser will throw an error.
    If `parser` fails, this parser will succeed, consuming the input and returning nothing.

    - Parameter parser: The parser to run.
*/
public func not<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, ()> {
    return Parser { state in
        do {
            try parser.parse(state)
        } catch _ as ParseError {
            return ()
        }
        throw ParseError("not(\(parser))")
    }
}

/**
    Constructs a `Parser` that will run `condition` without consuming any input and return nothing.
    This parser throws an error whenever the `condition` parser throws an error.

    - Parameter condition: The parser that must succeed to continue.
*/
public func precondition<Token, Discard>(condition: Parser<Token, Discard>) -> Parser<Token, ()> {
    return lookahead(condition).discard()
}

/**
    Constructs a `Parser` that will run first run `condition` without consuming any input. If it succeeds,
    `parse` will be run and its result will be returned. If either fails, `ifThen` will fail.

    - Parameter condition: The parser that will consume no input and must succeed for `parse` to run.
    - Parameter parse: The parser that determines the result.
*/
public func ifThen<Token, Discard, Result>(condition: Parser<Token, Discard>, _ parse: Parser<Token, Result>) -> Parser<Token, Result> {
    return rightResult(precondition(condition), parse)
}

/**
    Constructs a `Parser` that will repeatedly run `condition` without consuming any input. Each time
    `condition` succeeds, `parse` will be run. Once `condition` fails, an array of the results from
    previous invocations of `parse` will be returned.

    - Parameter condition: The parser that will consume no input and must succeed before each `parse` run.
    - Parameter parse: The parser that is run over and over to determine the result.
*/
public func until<Token, Discard, Result>(condition: Parser<Token, Discard>, parse: Parser<Token, Result>) -> Parser<Token, [Result]> {
    return many(ifThen(condition, parse))
}

/**
    Constructs a `Parser` that will repeatedly run `condition` without consuming any input. Each time
    `condition` succeeds, `parse` will be run. Once `condition` fails, an string obtained by appending
    character results from previous invocations of `parse` will be returned.

    - Parameter condition: The parser that will consume no input and must succeed before each `parse` run.
    - Parameter parse: The parser that is run over and over to determine the result.
*/
public func until<Result>(parser: Parser<Character, Result>) -> Parser<Character, String> {
    return until(parser).map { String($0) }
}

//
//public func through<Token>(parser: Parser<Token, [Token]>) -> Parser<Token, [Token]> {
//    return sequence(until(parser), parser).map { rest, last in rest + last }
//}
//
//public func through<Token>(parser: Parser<Token, Token>) -> Parser<Token, [Token]> {
//    return through(parser.map { [$0] })
//}
//
//public func through(parser: Parser<Character, String>) -> Parser<Character, String> {
//    return through(parser.map { Array($0.characters) }).map(String.init)
//}
//
//public func through(parser: Parser<Character, Character>) -> Parser<Character, String> {
//    return through(parser).map { String($0) }
//}

