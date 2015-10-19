//
//  AnyParser.swift
//  Parsley
//
//  Created by Jaden Geller on 10/13/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Spork

public protocol StreamType: class, BooleanType {
    typealias Token
    var state: ParseState<Token> { get }
    var error: ParseError? { get set }
    
    func combinator<Result>(parser: Parser<Token, Result>) -> Parser<Token, Result>
}

extension StreamType {
    public var boolValue: Bool {
        return error == nil
    }
}

extension StreamType {
    func match<Result>(parser: Parser<Token, Result>) -> Result? {
        do { return try combinator(parser).parse(state) }
        catch let x as ParseError { error = x } catch { }
        return nil
    }
}

public class InputStream<Token>: StreamType {
    public let state: ParseState<Token>
    public var error: ParseError?
    
    public init<Sequence: SequenceType where Sequence.Generator.Element == Token>(sequence: Sequence) {
        self.state = ParseState(bridgedFromGenerator: sequence.generate())
    }
    
    public init<Sequence: SequenceType where Sequence.Generator: ForkableGeneratorType, Sequence.Generator.Element == Token>(sequence: Sequence) {
        self.state = ParseState(forkableGenerator: sequence.generate())
    }
    
    public func combinator<Result>(parser: Parser<Token, Result>) -> Parser<Token, Result> {
        return parser
    }
}

public class TextStream: StreamType {
    public let state: ParseState<Character>
    public var error: ParseError?
    public var ignoreWhitespace = true
    
    public init(_ string: String) {
        state = ParseState(forkableGenerator: string.characters.generate())
    }
    
    public func combinator<Result>(parser: Parser<Character, Result>) -> Parser<Character, Result> {
        return dropLeft(many(whitespace()), parser)
    }
}
