//
//  Parsable.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

//public protocol Parsable {
//    typealias TokenInput = Character
//    static var parser: Parser<TokenInput, Self> { get }
//}
//
//extension Parsable {
//    public static func parse<S: SequenceType where S.Generator.Element == TokenInput>(sequence: S) -> Self? {
//        return try? terminating(parser).parse(sequence)
//    }
//}
//
//extension Parsable where TokenInput == Character {
//    public static func parse(string: String) -> Self? {
//        return parse(string.characters)
//    }
//}
