//
//  ParseState.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Spork

/// Represents the state of the parser. Stores the generator from which the subsequent symbols to parse
/// are obtained.
public class ParseState<Token> {
    private var backing: AnyForkableGenerator<Token>
    public var lookbehind: Token?
    
    private init<Generator: ForkableGeneratorType where Generator.Element == Token>(_ generator: Generator) {
        self.backing = AnyForkableGenerator(generator)
    }
}

extension ParseState {
    /// Construct a `ParseState` from a forkable sequence. Provided as an optimization.
    public convenience init<Sequence: SequenceType where Sequence.Generator: ForkableGeneratorType, Sequence.Generator.Element == Token>(_ sequence: Sequence) {
        self.init(AnyForkableGenerator(sequence.generate()))
    }
    
    /// Construct a `ParseState` from any sequence.
    public convenience init<Sequence: SequenceType where Sequence.Generator.Element == Token>(_ sequence: Sequence) {
        self.init(AnyForkableGenerator(BufferingGenerator(bridgedFromGenerator: sequence.generate())))
    }
    
    /// Returns the next token from the generator, otherwise throws a `ParseError` if no more tokens are availible.
    public func read() throws -> Token {
        guard let next = backing.next() else { throw ParseError.EndOfSequence }
        lookbehind = next
        return next
    }
    
    public var lookahead: Token? {
        let saved = checkpoint()
        defer { restore(saved) }
        return try? read()
    }
}

/// Provides backtracking capabilities by allowing a `ParseState` to be saved and restored.
public struct ParseStateCheckpoint<Token> {
    private let backing: AnyForkableGenerator<Token>
    private let lookbehind: Token?
}

extension ParseState {
    /// Save the current `ParseState` for later restoration.
    @warn_unused_result public func checkpoint() -> ParseStateCheckpoint<Token> {
        return ParseStateCheckpoint(backing: backing.fork(), lookbehind: lookbehind)
    }
    
    /// Restore the `ParseState` to what is was when `checkpoint` was created.
    public func restore(checkpoint: ParseStateCheckpoint<Token>) {
        backing = checkpoint.backing
        lookbehind = checkpoint.lookbehind
    }
}
