//
//  Matchable.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol Enumeratable {
    static var all: [Self] { get }
}

public protocol Matchable: Parsable, Enumeratable {
    var matcher: Parser<TokenInput, ()> { get }
}

extension Matchable {
    public static var parser: Parser<TokenInput, Self> {
        return coalesce(Self.all.map{ $0.matcher.replace($0) })
    }
}