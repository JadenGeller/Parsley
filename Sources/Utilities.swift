//
//  Utilities.swift
//  Parsley
//
//  Created by Jaden Geller on 1/19/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public func left<A, B>(tuple: (A, B)) -> A {
    return tuple.0
}

public func right<A, B>(tuple: (A, B)) -> B {
    return tuple.1
}

/**
    Constructs a `Parser` that will run `parser` 1 or more times, as many times as possible parsing `parser`
    separated by `delimiter`.

    - Parameter parser: The parser to run repeatedly.
    - Parameter delimiter: The parser to separate each occurance of `parser`.
*/
@warn_unused_result public func separated<Token, Result, Discard>(by1 parser: Parser<Token, Result>, delimiter: Parser<Token, Discard>) -> Parser<Token, [Result]> {
    return prepend(parser, many(pair(delimiter, parser).map(right)))
}

/**
    Constructs a `Parser` that will run `parser` 0 or more times, as many times as possible parsing `parser`
    separated by `delimiter`.
 
    - Parameter parser: The parser to run repeatedly.
    - Parameter delimiter: The parser to separate each occurance of `parser`.
 */
@warn_unused_result public func separated<Token, Result, Discard>(by parser: Parser<Token, Result>, delimiter: Parser<Token, Discard>) -> Parser<Token, [Result]> {
    return optional(separated(by1: parser, delimiter: delimiter))
}

/**
    Constructs a `Parser` that will run `left` followed by `parser` followed by `right`,
    discarding the result from `left` and `right` and returning the result from `parser`.
 
    - Parameter left: The first parser whose result will be discarded.
    - Parameter right: The second parser whose result will be discarded.
    - Parameter parser: The parser that will be run between the other two parsers.
*/
public func between<Token, LeftIgnore, RightIgnore, Result>(leftParser: Parser<Token, LeftIgnore>, _ rightParser: Parser<Token, RightIgnore>, parse parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return pair(leftParser, pair(parser, rightParser).map(left)).map(right)
}

//public func infix2<Token, InfixResult, LeftResult, RightResult, Result>(infixParser: Parser<Token, InfixResult>, between leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>, mapping: InfixResult -> (LeftResult, RightResult) -> Result) -> Parser<Token, Result> {
//    return Parser { state in
//        let left = try leftParser.wrapError("left").parse(state)
//        let infix = try infixParser.parse(state)
//        let right = try rightParser.wrapError("right").parse(state)
//        return mapping(infix)(left, right)
//    }
//}

public func infix<Token, InfixResult, LeftResult, RightResult>(infixParser: Parser<Token, InfixResult>, between leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, (LeftResult, RightResult)> {
    return Parser { state in
        let left = try leftParser.wrapError("left").parse(state)
        try infixParser.parse(state)
        let right = try rightParser.wrapError("right").parse(state)
        return (left, right)
    }
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
