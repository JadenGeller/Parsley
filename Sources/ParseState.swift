//
//  ParseState.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Spork

public final class ParseState<Token> {
    private var backing: AnyForkableGenerator<Token>
    
    private init<Generator: ForkableGeneratorType where Generator.Element == Token>(_ generator: Generator) {
        self.backing = AnyForkableGenerator(generator)
    }
}

extension ParseState {
    public convenience init<Sequence: SequenceType where Sequence.Generator: ForkableGeneratorType, Sequence.Generator.Element == Token>(_ sequence: Sequence) {
        self.init(AnyForkableGenerator(sequence.generate()))
    }
    
    public convenience init<Sequence: SequenceType where Sequence.Generator.Element == Token>(_ sequence: Sequence) {
        self.init(AnyForkableGenerator(BufferingGenerator(bridgedFromGenerator: sequence.generate())))
    }
    
    public func read() throws -> Token {
        guard let next = backing.next() else { throw ParseError.EndOfSequence }
        return next
    }
}

public struct ParseStateCheckpoint<Token> {
    private let backing: AnyForkableGenerator<Token>
}

extension ParseState {
    @warn_unused_result public func checkpoint() -> ParseStateCheckpoint<Token> {
        return ParseStateCheckpoint(backing: backing.fork())
    }
    
    public func restore(checkpoint: ParseStateCheckpoint<Token>) {
        backing = checkpoint.backing
    }
}
