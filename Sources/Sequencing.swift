//
//  Sequencing.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that will parse will each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.

    - Parameter parsers: The sequence of parsers to sequentially run.
*/
public func sequence<Token, Result, Sequence: SequenceType where Sequence.Generator.Element == Parser<Token, Result>> (parsers: Sequence) -> Parser<Token, [Result]> {
    return Parser { state in
        var results = [Result]()
        for parser in parsers {
            results.append(try parser.parse(state))
        }
        return results
    }
}

/**
    Constructs a `Parser` that will parse will each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.
 
    - Parameter parsers: The variadic list of parsers to sequentially run.
*/
public func sequence<Token, Result>(parsers: Parser<Token, Result>...) -> Parser<Token, [Result]> {
    return sequence(parsers)
}

/**
    Constructs a `Parser` that will run the passed-in parsers sequentially. Parsing only succeeds if both
    parsers succeed, and the resulting parser returns an tuple of the results.
*/
@warn_unused_result public func pair<Token, LeftResult, RightResult>(leftParser: Parser<Token, LeftResult>, _ rightParser: Parser<Token, RightResult>) -> Parser<Token, (LeftResult, RightResult)> {
    return leftParser.flatMap { a in
        rightParser.map { b in
            return (a, b)
        }
    }
}

/**
    Constructs a `Parser` that will parse will each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.
 
    - Parameter parsers: The sequence of parsers to sequentially run.
*/
public func concat<Token, Result, Sequence: SequenceType where Sequence.Generator.Element == Parser<Token, [Result]>>(parsers: Sequence) -> Parser<Token, [Result]> {
        return sequence(parsers).map{ Array($0.flatten()) }
}

/**
    Constructs a `Parser` that will parse will each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.
 
    - Parameter parsers: The variadic list of parsers to sequentially run.
*/
public func concat<Token, Result>(parsers: Parser<Token, [Result]>...) -> Parser<Token, [Result]> {
        return concat(parsers)
}

/**
 Constructs a `Parser` that will parse will each element of `parsers`, sequentially. Parsing only succeeds if every
 parser succeeds, and the resulting parser returns an array of the results.
 
 - Parameter parsers: The variadic list of parsers to sequentially run.
 */
public func +<Token, Result>(left: Parser<Token, [Result]>, right: Parser<Token, [Result]>) -> Parser<Token, [Result]> {
    return concat(left, right)
}
