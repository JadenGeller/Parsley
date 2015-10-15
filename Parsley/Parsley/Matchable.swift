//
//  Literate.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

// MARK: Protocols

protocol MatchInitializable {
    typealias Token
    static var matcher: Parser<Token, Self> { get }
}

protocol MatchVerifiable {
    typealias Token
    var matcher: Parser<Token, Self> { get }
}

// MARK: Operators

infix operator ->> { associativity left }

func ->><Stream: StreamType, Result: MatchInitializable where Stream.Token == Result.Token>(stream: Stream, inout result: Result!) -> Stream {
    result = stream.match(Result.matcher)
    return stream
}

func ->><Stream: StreamType, Result: MatchInitializable where Stream.Token == Result.Token>(stream: Stream, result: Result.Type) -> Stream {
    stream.match(Result.matcher)
    return stream
}

func ->><Stream: StreamType, Expected: MatchVerifiable where Stream.Token == Expected.Token>(stream: Stream, expected: Expected) -> Stream {
    stream.match(expected.matcher)
    return stream
}

// MARK: Parsers

func type<Result: MatchInitializable>(type: Result.Type) -> Parser<Result.Token, Result> {
    return Result.matcher
}

