//
//  Parser.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Spork

/// A protocol to which `Parser` conforms. Exists as a workaround to the current 
/// Swift limitation that extensions cannot make concrete type non-generic.
public protocol ParserType {
    /// The type whose sequence is parsed by the parser.
    associatedtype Token
    
    /// The type that results from the parsing.
    associatedtype Result
    
    @warn_unused_result func parse(state: ParseState<Token>) throws -> Result
}

/// A parser whose `parse` function mutates a `ParseState<Token>` and returns a `Result`.
public struct Parser<Token, Result>: ParserType {
    internal let implementation: ParseState<Token> throws -> Result
    internal let name: String
    
    /// Construct a `Parser` that will run `implementation`.
    public init(_ implementation: ParseState<Token> throws -> Result, name: String) {
        self.implementation = implementation
        self.name = name
    }

    public init(_ implementation: ParseState<Token> throws -> Result) {
        self.implementation = implementation
        self.name = ""
    }

    /**
        Runs the parser on the passed in `state`, potentially mutating the state.
     
        - Parameter state: The state representing remaining input to be parsed.
     
        - Throws: `ParseError` if unable to parse.
        - Returns: The resulting parsed value.
    */
    public func parse(state: ParseState<Token>) throws -> Result {
        return try implementation(state)
    }
}

extension ParserType {
    /**
        Runs the parser on the passed in `sequence`.
     
        - Parameter sequence: The sequence to be parsed.
     
        - Throws: `ParseError` if unable to parse.
        - Returns: The resulting parsed value.
    */
    @warn_unused_result public func parse<Sequence: SequenceType where Sequence.Generator: ForkableGeneratorType, Sequence.Generator.Element == Token>(sequence: Sequence) throws -> Result {
        return try parse(ParseState(sequence))
    }
    
    /**
        Runs the parser on the passed in `sequence`.
     
        - Parameter sequence: The sequence to be parsed.
     
        - Throws: `ParseError` if unable to parse.
        - Returns: The resulting parsed value.
    */
    @warn_unused_result public func parse<Sequence: SequenceType where Sequence.Generator.Element == Token>(sequence: Sequence) throws -> Result {
        return try parse(ParseState(sequence))
    }
}

extension Parser {
    /**
        Returns a `Parser` that, on successful parse, continues parsing with the parser resulting
        from mapping `transform` over its result value; returns the result of this new parser.
     
        Can be used to chain parsers together sequentially.
     
        - Parameter transform: The transform to map over the result.
    */
    @warn_unused_result public func flatMap<MappedResult>(transform: Result throws -> Parser<Token, MappedResult>) -> Parser<Token, MappedResult> {
        return Parser<Token, MappedResult> { state in
            return try transform(self.parse(state)).parse(state)
        }
    }
    
    /**
        Returns a `Parser` that, on successful parse, returns the result of mapping `transform`
        over its previous result value
     
        - Parameter transform: The transform to map over the result.
    */
    @warn_unused_result public func map<MappedResult>(transform: Result throws -> MappedResult) -> Parser<Token, MappedResult> {
        return Parser<Token, MappedResult>({ state in
            return try transform(self.parse(state))
        }, name: name)
    }
    
    /**
        Returns a `Parser` that, on successful parse, discards its previous result and returns `value` instead.
     
        - Parameter value: The value to return on successful parse.
    */
    @warn_unused_result public func replace<NewResult>(value: NewResult) -> Parser<Token, NewResult> {
        return map { _ in value }
    }
    
    /**
        Returns a `Parser` that, on successful parse, discards its result.
    */
    @warn_unused_result public func discard() -> Parser<Token, ()> {
        return replace(())
    }
    
    /**
        Returns a `Parser` that calls the callback `glimpse` before returning its result.
     
        - Parameter glimpse: Callback that recieves the parser's result as input.
    */
    @warn_unused_result public func peek(glimpse: Result throws -> ()) -> Parser<Token, Result> {
        return map { result in
            try glimpse(result)
            return result
        }
    }
    
    /**
        Returns a `Parser` that verifies that its result passes the condition before returning
        its result. If the result fails the condition, throws an error.
     
        - Parameter condition: The condition used to test the result.
    */
    @warn_unused_result public func require(condition: Result -> Bool) -> Parser<Token, Result> {
        return peek { result in
            if !condition(result) { throw ParseError.UnableToMatch("require") }
        }
    }
}

extension Parser {
    /**
        Converts a parser that results in an elemnt into a parser that results in an Array.
    */
    @warn_unused_result public func lift() -> Parser<Token, [Result]> {
        return map { [$0] }
    }
}

extension Parser {
    public func debug(message: String) -> Parser {
        let wrapped = message + (name == "" ? "" : ("(" + name + ")"))
        return Parser({ state in
            print("\(wrapped) attempting...")
            print("\(state.lookahead) next...")
            return try self.parse(state)
        }, name: wrapped
        ).peek { result in
                print("\(wrapped) success: \(result)")
            }.mapError { error in
                print("\(wrapped) error: \(error)")
                return error
        }
    }
}

