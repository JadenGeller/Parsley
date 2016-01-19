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
    Constructs a `Parser` that will parse each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.
 
    - Parameter parsers: The sequence of parsers to sequentially run.
*/
public func concat<Token, Result, Sequence: SequenceType where Sequence.Generator.Element == Parser<Token, [Result]>>(parsers: Sequence) -> Parser<Token, [Result]> {
        return sequence(parsers).map{ Array($0.flatten()) }
}

/**
    Constructs a `Parser` that will parse each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.
 
    - Parameter parsers: The variadic list of parsers to sequentially run.
*/
public func concat<Token, Result>(parsers: Parser<Token, [Result]>...) -> Parser<Token, [Result]> {
        return concat(parsers)
}

/**
    Constructs a `Parser` that will parse each element of `parsers`, sequentially. Parsing only succeeds if every
    parser succeeds, and the resulting parser returns an array of the results.
 
    - Parameter parsers: The variadic list of parsers to sequentially run.
*/
public func +<Token, Result>(left: Parser<Token, [Result]>, right: Parser<Token, [Result]>) -> Parser<Token, [Result]> {
    return concat(left, right)
}

/**
    Constructs a `Parser` that will parse `first` and then will parse `others`, prepending the result of `first`
    to the result of `others`.
 
    - Parameter first: The first parser to run whose result will be prepended to the result of `others`.
    - Parameter others: The second parser to run. The result should be an array.
*/
public func prepend<Token, Result>(first: Parser<Token, Result>, _ others: Parser<Token, [Result]>) -> Parser<Token, [Result]> {
    return pair(first, others).map{ [$0] + $1 }
}


/**
    Constructs a `Parser` that will parse `others` and then will parse `last`, appending the result of `last`
    to the result of `others`.
 
 - Parameter others: The first parser to run. The result should be an array.
 - Parameter last: The last parser to run whose result will be appended to the result of `others`.
 
 */
public func append<Token, Result>(others: Parser<Token, [Result]>, _ last: Parser<Token, Result>) -> Parser<Token, [Result]> {
    return pair(others, last).map{ $0 + [$1] }
}



