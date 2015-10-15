//
//  Extensions.swift
//  Parsley
//
//  Created by Jaden Geller on 10/14/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

extension String: MatchInitializable, MatchVerifiable {
    static var matcher: Parser<Character, String> {
        return many1(letter()).map(String.init)
    }
    
    var matcher: Parser<Character, String> {
        return string(self).replace(self)
    }
}

extension Int: MatchInitializable, MatchVerifiable {
    static var matcher: Parser<Character, Int> {
        return many1(digit()).map{ Int(String($0))! }
    }
    
    var matcher: Parser<Character, Int> {
        return sequence(many(token("0")),string(String(self))).replace(self)
    }
}
