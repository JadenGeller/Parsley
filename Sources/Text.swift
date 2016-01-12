//
//  Text.swift
//  Parsley
//
//  Created by Jaden Geller on 1/12/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Spork

extension ParserType where Token == Character {
    /**
     Runs the parser on the passed in `sequence`.
     
     - Parameter sequence: The sequence to be parsed.
     
     - Throws: `ParseError` if unable to parse.
     - Returns: The resulting parsed value.
     */
    public func parse(string: String) throws -> Result {
        return try parse(ParseState(string.characters))
    }
}

extension Parser where Result: SequenceType, Result.Generator.Element == Character {
    /**
     Converts a parser that results in a sequence of characters into a parser that
     results in a String.
     */
    @warn_unused_result public func stringify() -> Parser<Token, String> {
        return map { String($0) }
    }
}

/**
    Construct a `Parser` that matches a given character.
 
    - Parameter character: The character to match against.
*/
@warn_unused_result public func character(character: Character) -> Parser<Character, Character> {
    return token(character).withError("character(\(character))")
}

/**
    Constructs a `Parser` that matches a given string of text.
 
    - Parameter text: The string of text to match against.
*/
@warn_unused_result public func string(text: String) -> Parser<Character, [Character]> {
    return sequence(text.characters.map(token)).withError("string(\(text)")
}

/**
    Constructs a `Parser` that succeeds upon consuming a letter
    from the English alphabet.
 */
@warn_unused_result public func letter() -> Parser<Character, Character> {
    return within("A"..."z").withError("letter")
}

/**
    Constructs a `Parser` that succeeds upon consuming an
    Arabic numeral.
*/
@warn_unused_result public func digit() -> Parser<Character, Character> {
    return within("0"..."9").withError("digit")
}

/**
    Constructs a `Parser` that succeeds upon consuming a space character.
*/
@warn_unused_result public func space() -> Parser<Character, Character> {
    return token(" ").withError("space")
}

/**
    Constructs a `Parser` that skips zero or more space characters.
*/
@warn_unused_result public func spaces() -> Parser<Character, ()> {
    return many(space()).discard()
}

/**
    Constructs a `Parser` that succeeds upon consuming a new line character.
*/
@warn_unused_result public func newline() -> Parser<Character, Character> {
    return token("\n").withError("newline")
}

/**
    Constructs a `Parser` that succeeds upon consuming a tab character.
*/
@warn_unused_result public func tab() -> Parser<Character, Character> {
    return token("\t").withError("tab")
}

/**
    Constructs a `Parser` that succeeds upon consuming an uppercase letter.
*/
@warn_unused_result public func uppercaseLetter() -> Parser<Character, Character> {
    return within("A"..."Z").withError("uppercaseLetter")
}

/**
 Constructs a `Parser` that succeeds upon consuming an lowercase letter.
 */
@warn_unused_result public func lowercaseLetter() -> Parser<Character, Character> {
    return within("a"..."z").withError("lowercaseLetter")
}

/**
    Constructs a `Parser` that consumes a single token and returns the token
    if it is within the string `text`.
 
    - Parameter text: The `String` that the input is tested against.
*/
@warn_unused_result public func within(text: String) -> Parser<Character, Character> {
    return oneOf(text.characters)
}

