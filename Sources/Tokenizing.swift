//
//  Tokenizing.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//






//// TODO: Useless function?
//public func skipping<Token, Ignore, Result>(skippingParser: Parser<Token, Ignore>, parse parser: Parser<Token, Result>) -> Parser<Token, Result> {
//    return pair(skippingParser, parser).map(right)
//}
//
//public func tokens<Token: Parsable, Ignore>(type: Token.Type, optionallyDelimitedBy delimiterParser: Parser<Token.Input, Ignore>) -> Parser<Token.Input, [Token]> {
//    return tokens(type.parser, optionallyDelimitedBy: delimiterParser)
//}
//
//public func tokens<Input, Ignore, Token>(parsers: Parser<Input, Token>, optionallyDelimitedBy delimiterParser: Parser<Input, Ignore>) -> Parser<Input, [Token]> {
//    return many(skipping(delimiterParser, parse: parsers))
//}
