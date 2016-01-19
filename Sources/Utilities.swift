//
//  Utilities.swift
//  Parsley
//
//  Created by Jaden Geller on 1/19/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that will run `leftParser` followed by `rightParser`, discarding the result from
    `rightParser` and returning the result from `leftParser`.

    - Parameter leftParser: The parser whose result will be propagated.
    - Parameter rightParser: The parser whose result will be discarded.
*/
public func dropRight<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, LeftResult> {
    return pair(leftParser, rightParser).map { left, _ in left }
}

/**
    Constructs a `Parser` that will run `leftParser` followed by `rightParser`, discarding the result from
    `leftParser` and returning the result from `rightParser`.
 
    - Parameter leftParser: The parser whose result will be discarded.
    - Parameter rightParser: The parser whose result will be propagated.
*/
public func dropLeft<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, RightResult> {
    return pair(leftParser, rightParser).map { _, right in right }
}

/**
    Constructs a `Parser` that will run `parser` 1 or more times, as many times as possible parsing `parser`
    separated by `delimiter`.

    - Parameter parser: The parser to run repeatedly.
    - Parameter delimiter: The parser to separate each occurance of `parser`.
*/
@warn_unused_result public func separatedBy1<Token, Result, Discard>(parser: Parser<Token, Result>, delimiter: Parser<Token, Discard>) -> Parser<Token, [Result]> {
    return prepend(parser, many(dropLeft(delimiter, parser)))
}

/**
    Constructs a `Parser` that will run `parser` 0 or more times, as many times as possible parsing `parser`
    separated by `delimiter`.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter delimiter: The parser to separate each occurance of `parser`.
 */
@warn_unused_result public func separatedBy<Token, Result, Discard>(parser: Parser<Token, Result>, delimiter: Parser<Token, Discard>) -> Parser<Token, [Result]> {
    return optional(separatedBy1(parser, delimiter: delimiter))
}

/**
    Constructs a `Parser` that will run `left` followed by `parser` followed by `right`,
    discarding the result from `left` and `right` and returning the result from `parser`.
 
    - Parameter left: The first parser whose result will be discarded.
    - Parameter right: The second parser whose result will be discarded.
    - Parameter parser: The parser that will be run between the other two parsers.
*/
public func between<Token, LeftIgnore, RightIgnore, Result>(left: Parser<Token, LeftIgnore>, _ right: Parser<Token, RightIgnore>, parse parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return dropLeft(left, dropRight(parser, right))
}

/**
    Constructs a `Parser` that will run `left` followed by `parser` followed by `right`,
    discarding the result from `left` and `right` and returning the result from `parser`.
 
    - Parameter side: The first and last parser whose result will be discarded.
    - Parameter parser: The parser that will be run between the other two parsers.
 */
public func between<Token, Ignore, Result>(side: Parser<Token, Ignore>, parse parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return between(side, side, parse: parser)
}
