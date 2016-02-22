//
//  ParseError.swift
//  Parsley
//
//  Created by Jaden Geller on 1/11/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// An error thrown when parsing fails.
public enum ParseError: ErrorType {
    case EndOfSequence
    case UnableToMatch(String)
}

extension ParserType {
    /**
        Constructs a `Parser` that, on error, catches the error and attempts to recover by running the `Parser` obtained from passing the error to `recovery`.
     
        - Parameter recovery: A function that, given the error, will return a new parser to attempt.
    */
    @warn_unused_result public func recover(recovery: ParseError throws -> Parser<Token, Result>) -> Parser<Token, Result> {
        return Parser { state in
            do {
                return try self.parse(state)
            } catch let error as ParseError {
                return try recovery(error).parse(state)
            }
        }
    }
    
    /**
        Constructs a `Parser` that, on error, catches the error and rethrows the transformed error.
     
        - Parameter transform: The transform to map onto the caught message.
    */
    @warn_unused_result public func mapError(transform: ParseError -> ParseError) -> Parser<Token, Result> {
        return Parser { state in
            do {
                return try self.parse(state)
            } catch let error as ParseError {
                throw transform(error)
            }
        }
    }
    
    @warn_unused_result public func wrapError(outer: String) -> Parser<Token, Result> {
        return mapError { error in
            switch error {
            case .EndOfSequence: return .EndOfSequence
            case .UnableToMatch(let inner): return .UnableToMatch(outer + "(" + inner + ")")
            }
        }
    }
}

extension Parser {
    /**
     Constructs a `Parser` that, on error, discards the previously thrown error and throws instead
     a new `UnableToMatch` error with the given message.
     
     - Parameter description: The description to include in the error.
     */
    @warn_unused_result public func withError(description: String) -> Parser<Token, Result> {
        return Parser(implementation, name: description).mapError { _ in ParseError.UnableToMatch(description) }
    }
}
