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
 Constructs a `Parser` that consumes a single token and returns the token
 if it is within the string `text`.
 
 - Parameter text: The `String` that the input is tested against.
 */
@warn_unused_result public func within(text: String) -> Parser<Character, Character> {
    return oneOf(text.characters).withError("within(\(text))")
}

/**
    A `Parser` that succeeds upon consuming a letter from the English alphabet.
 */
public let letter = within("A"..."z").withError("letter")

/**
    A `Parser` that succeeds upon consuming an Arabic numeral.
*/
public let digit = within("0"..."9").withError("digit")

/**
    Constructs a `Parser` that succeeds upon consuming a space character.
*/
public let space = token(" ").withError("space")

/**
    Constructs a `Parser` that skips zero or more space characters.
*/
public let spaces = many(space).discard()

/**
    Constructs a `Parser` that succeeds upon consuming a new line character.
*/
public let newLine = token("\n").withError("newline")

/**
    Constructs a `Parser` that succeeds upon consuming a tab character.
*/
public let tab = token("\t").withError("tab")

/**
    Constructs a `Parser` that skips zero or more space characters.
*/
public let whitespace = many(space ?? newLine ?? tab).discard().withError("whitespace")

/**
    Constructs a `Parser` that succeeds upon consuming an uppercase letter.
*/
public let uppercaseLetter = within("A"..."Z").withError("uppercaseLetter")

/**
 Constructs a `Parser` that succeeds upon consuming an lowercase letter.
 */
public let lowercaseLetter = within("a"..."z").withError("lowercaseLetter")

