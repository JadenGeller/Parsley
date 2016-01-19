//
//  Repeating.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that will run `parser` 0 or more times, as many times as possible,
    and will result in an array of the results from each invocation.

    - Parameter parser: The parser to run repeatedly.
*/
@warn_unused_result public func many<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, [Result]> {
    return Parser { state in
        var results = [Result]()
        do {
            while true {
                results.append(try attempt(parser).parse(state))
            }
        }
        catch _ as ParseError { }
        return results
    }
}

/**
    Constructs a `Parser` that will run `parser` 1 or more times, as many times as possible,
    and will result in an array of the results from each invocation.
 
    - Parameter parser: The parser to run repeatedly.
 */
@warn_unused_result public func many1<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, [Result]> {
    return parser.flatMap { firstResult in
        many(parser).map { otherResults in
            [firstResult] + otherResults
        }
    }
}

/**
    Constructs a `Parser` that will run `parser` 0 or more times, as many times as possible,
    and then will run `then`. If `then` fails, the parser will undo runs of `parser` until `then`
    succeeds, otherwise will throw a `ParseError`. On success, returns a tuple with the resulting
    array from applying `parser` on the left and with the result of `then` on the right.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter then: The parser whose success is desired after applications of `parser`.
    - Throws: `ParseError` if `then` does not succeed for any number of times that `parser` succeeds.
 */
@warn_unused_result public func many<Token, ManyResult, ThenResult>(parser: Parser<Token, ManyResult>, then: Parser<Token, ThenResult>) -> Parser<Token, ([ManyResult], ThenResult)> {
    return Parser { state in
        var results: [ManyResult] = []
        var checkpoints = [state.checkpoint()]
        do {
            while true {
                results.append(try parser.parse(state))
                checkpoints.append(state.checkpoint())
            }
        }
        catch _ as ParseError {
            while true {
                let checkpoint = checkpoints.popLast()!
                state.restore(checkpoint)
                do {
                    return (results, try then.parse(state))
                }
                catch let error as ParseError {
                    results.removeLast()
                    guard !checkpoints.isEmpty else { throw error }
                }
            }
        }
    }
}

/**
    Constructs a `Parser` that will run `parser` 1 or more times, as many times as possible,
    and then will run `then`. If `then` fails, the parser will undo runs of `parser` until `then`
    succeeds, otherwise will throw a `ParseError`. On success, returns a tuple with the resulting
    array from applying `parser` on the left and with the result of `then` on the right.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter then: The parser whose success is desired after applications of `parser`.
    - Throws: `ParseError` if `then` does not succeed for any number of times that `parser` succeeds.
 */
@warn_unused_result public func many1<Token, ManyResult, ThenResult>(parser: Parser<Token, ManyResult>, then: Parser<Token, ThenResult>) -> Parser<Token, ([ManyResult], ThenResult)> {
    return parser.flatMap { firstResult in
        many(parser, then: then).map { otherResults, thenResult in
            ([firstResult] + otherResults, thenResult)
        }
    }
}

/**
    Constructs a `Parser` that will run `parser` 0 or more times, as few times as possible,
    such that `then` will succeed afterwards. If no number of successful applications of
    `parser` allows `then` to succeed, throws a `ParseError`. On success, returns a tuple
    with the resulting array from applying `parser` on the left and with the result of `then`
    on the right.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter then: The parser whose success is desired after applications of `parser`.
    - Throws: `ParseError` if `then` does not succeed for any number of times that `parser` succeeds.
 */
@warn_unused_result public func few<Token, ManyResult, ThenResult>(parser: Parser<Token, ManyResult>, then: Parser<Token, ThenResult>) -> Parser<Token, ([ManyResult], ThenResult)> {
    return Parser { state in
        var results = [ManyResult]()
        while true {
            do {
                return (results, try attempt(then).parse(state))
            }
            catch _ as ParseError {
                results.append(try parser.parse(state))
            }
        }
    }
}

/**
    Constructs a `Parser` that will run `parser` 1 or more times, as few times as possible,
    such that `then` will succeed afterwards. If no number of successful applications of
    `parser` allows `then` to succeed, throws a `ParseError`. On success, returns a tuple
    with the resulting array from applying `parser` on the left and with the result of `then`
    on the right.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter then: The parser whose success is desired after applications of `parser`.
    - Throws: `ParseError` if `then` does not succeed for any number of times that `parser` succeeds.
*/
@warn_unused_result public func few1<Token, ManyResult, ThenResult>(parser: Parser<Token, ManyResult>, then: Parser<Token, ThenResult>) -> Parser<Token, ([ManyResult], ThenResult)> {
    return parser.flatMap { firstResult in
        few(parser, then: then).map { otherResults, thenResult in
            ([firstResult] + otherResults, thenResult)
        }
    }
}

/**
    Constructs a `Parser` that will run `parser` exactly `count` times and will result in an array
    of the results from each invocation.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter exactCount: The number of times to run `parser`.
 */
@warn_unused_result public func repeated<Token, Result>(parser: Parser<Token, Result>, exactCount: Int) -> Parser<Token, [Result]> {
    return Parser { state in
        var results = [Result]()
        for _ in 0..<exactCount {
            results.append(try parser.parse(state))
        }
        return results
    }
}

/**
    Constructs a `Parser` that will run `parser` a maximum of `count` times and will result in an array
    of the results from each invocation.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter maxCount: The maximum number of times to run `parser`.
 */
@warn_unused_result public func repeated<Token, Result>(parser: Parser<Token, Result>, maxCount: Int) -> Parser<Token, [Result]> {
    return Parser { state in
        var results = [Result]()
        while results.count < maxCount {
            do {
                results.append(try attempt(parser).parse(state))
            }
            catch _ as ParseError {
                break
            }
        }
        return results
    }
}

/**
    Constructs a `Parser` that will run `parser` a minimum of `count` times and will result in an array
    of the results from each invocation.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter minCount: The minimum number of times to run `parser`.
 */
@warn_unused_result public func repeated<Token, Result>(parser: Parser<Token, Result>, minCount: Int) -> Parser<Token, [Result]> {
    return pair(repeated(parser, exactCount: minCount), many(parser)).map(+)
}

/**
    Constructs a `Parser` that will run `parser` a number of times within `interval` and will result in an array
    of the results from each invocation.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter interval: The interval describing the allowed number of times to run parser.
 */
@warn_unused_result public func repeated<Token, Result>(parser: Parser<Token, Result>, betweenCount interval: ClosedInterval<Int>) -> Parser<Token, [Result]> {
    return pair(repeated(parser, exactCount: interval.start), repeated(parser, maxCount: interval.end - interval.start)).map(+)
}

/**
    Constructs a `Parser` that will run `parser` a number of times within `interval` and will result in an array
    of the results from each invocation.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter interval: The interval describing the allowed number of times to run parser.
 */
@warn_unused_result public func repeated<Token, Result>(parser: Parser<Token, Result>, betweenCount interval: HalfOpenInterval<Int>) -> Parser<Token, [Result]> {
    return repeated(parser, betweenCount: interval.start...interval.end.predecessor())
}

