//
//  Repeating.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

/**
    Constructs a `Parser` that will run `parser` 0 or more times, as many times as possible,
    and will result in an array of the results from each invocation.

    - Parameter parser: The parser to run repeatedly.
*/
public func many<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, [Result]> {
    return Parser { state in
        var results = [Result]()
        while let result = try? attempt(parser).parse(state) {
            results.append(result)
        }
        return results
    }
}

/**
    Constructs a `Parser` that will run `parser` 1 or more time, as many times as possible,
    and will result in an array of the results from each invocation.
*/
public func many1<Token, Result>(parser: Parser<Token, Result>) -> Parser<Token, [Result]> {
    return sequence(parser, many(parser)).map { first, rest in [first] + rest }
}
