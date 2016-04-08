//
//  Matchable.swift
//  Parsley
//
//  Created by Jaden Geller on 2/16/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

//// TODO: Bad protocol. Remove.
//public protocol Enumeratable {
//    static var all: [Self] { get }
//}
//
//// TODO: Remove enumerable conformance.
//public protocol Matchable: Parsable, Enumeratable {
//    var matcher: Parser<TokenInput, ()> { get }
//}
//
//
//
////extension Matchable: Parsable where Self: Enumerable { }
//extension Matchable {
//    public static var parser: Parser<TokenInput, Self> {
//        return coalesce(Self.all/*.sort{ $0.length > $1.length }*/.map{ $0.matcher.replace($0) })
//        // We can't do this unless we can get the lenght of a parser as a property of it. Even a
//        // range showing the min-max length would be useful.
//        // Ex. many(a).length = 0...Int.max
//        //     many1(a).length = (a.length)...Int.max
//        //     pair(a, b) -> a.length + b.length
//        // How would we choose how to order them though given this? Maybe only automatically create
//        // an ordered parser for equatable Enumerable things, not for Matchable (unless it provides an
//        // ordering). Maybe enumeratable is ordered and we have another type for unordered? idk.
//    }
//}