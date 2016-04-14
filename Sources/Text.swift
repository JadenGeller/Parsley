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
    return one(of: text.characters).withError("within(\(text))")
}

/**
    A `Parser` that succeeds upon consuming a letter from the English alphabet.
 */
public let letter: Parser<Character, Character> = within("A"..."z").withError("letter")

/**
    A `Parser` that succeeds upon consuming an Arabic numeral.
*/
public let digit: Parser<Character, Character> = within("0"..."9").withError("digit")

/**
    Constructs a `Parser` that succeeds upon consuming a new line character.
*/
public let newLine: Parser<Character, Character> = token("\n").withError("newline")

/**
    Constructs a `Parser` that succeeds upon consuming a tab character.
*/
public let tab: Parser<Character, Character> = token("\t").withError("tab")

/**
    Constructs a `Parser` that skips zero or more whitespace characters.
*/
public let spaces: Parser<Character, ()> = many(space).discard().withError("spaces")

/**
    Constructs a `Parser` that one whitespace character.
*/
public let space: Parser<Character, Character> = (token(" ") ?? newLine ?? tab).withError("space")

/**
    Constructs a `Parser` that succeeds upon consuming an uppercase letter.
*/
public let uppercaseLetter: Parser<Character, Character> = within("A"..."Z").withError("uppercaseLetter")

/**
 Constructs a `Parser` that succeeds upon consuming an lowercase letter.
 */
public let lowercaseLetter: Parser<Character, Character> = within("a"..."z").withError("lowercaseLetter")

