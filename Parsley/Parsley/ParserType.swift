//
//  ParserType.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Spork

protocol ParserType {
    typealias Token
    typealias Result
    
    func parse(state: ParseState<Token>) throws -> Result
}

extension ParserType {
    func parse<Sequence: SequenceType where Sequence.Generator: ForkableGeneratorType, Sequence.Generator.Element == Token>(sequence: Sequence) throws -> Result {
        return try parse(ParseState(sequence: sequence))
    }
    
    func parse<Sequence: SequenceType where Sequence.Generator.Element == Token>(sequence: Sequence) throws -> Result {
        return try parse(ParseState(sequence: sequence))
    }
}
