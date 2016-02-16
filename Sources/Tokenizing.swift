//
//  Tokenizing.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol Tokenizable {
    typealias Input = Character// TODO: Rename
    static var tokenizer: Parser<Input, Self> { get }
}

public protocol TokenSet: Tokenizable {
    static var all: [Self] { get }
    var matcher: Parser<Input, ()> { get }
}

extension TokenSet {
    public static var tokenizer: Parser<Input, Self> {
        return coalesce(Self.all.map{ $0.matcher.replace($0) })
    }
}

// TODO: Useless function?
public func skipping<Token, Ignore, Result>(skippingParser: Parser<Token, Ignore>, parse parser: Parser<Token, Result>) -> Parser<Token, Result> {
    return pair(skippingParser, parser).map(right)
}

public func tokens<Token: Tokenizable, Ignore>(type: Token.Type, optionallyDelimitedBy delimiterParser: Parser<Token.Input, Ignore>) -> Parser<Token.Input, [Token]> {
    return tokens(type.tokenizer, optionallyDelimitedBy: delimiterParser)
}

public func tokens<Input, Ignore, Token>(tokenizers: Parser<Input, Token>, optionallyDelimitedBy delimiterParser: Parser<Input, Ignore>) -> Parser<Input, [Token]> {
    return many(skipping(delimiterParser, parse: tokenizers))
}