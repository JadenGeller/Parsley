//
//  Tokenizing.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

//public func tokens<Token: Parsable where Token.TokenInput == Character>(type: Token.Type) -> Parser<Token.TokenInput, [Token]> {
//    return tokens(type.parser, delimitedBy: whitespace)
//}
//
//public func tokens<Token: Parsable, Ignore>(type: Token.Type, delimitedBy delimiterParser: Parser<Token.TokenInput, Ignore>) -> Parser<Token.TokenInput, [Token]> {
//    return tokens(type.parser, delimitedBy: delimiterParser)
//}
//
//public func tokens<Input, Ignore, Token>(parsers: Parser<Input, Token>, delimitedBy delimiterParser: Parser<Input, Ignore>) -> Parser<Input, [Token]> {
//    return many(pair(delimiterParser, parsers).map(right))
//}
//
