# Parsley

Parsley is a recursive descent parser combinator library that makes it simple to write complex, type-safe parsers in Swift.

## Lexing

It's super easy to define lexable types in Parsley! The simplest types to lex are those whose values can be enumerated and matched against the input. For example, if you'd like to lex a finite set of operators, your operator type can conform to `Matchable` and it will be automatically `Parsable`.

Conformance to `Matchable` simply requires a static member `all` listing all the possible values of that type and an instance member `matcher` that will only accept input that matches, throwing a `ParseError` otherwise.
```swift
enum Operator: String, Matchable {
    case Assignment = ":="
    case Lambda = "->"
    case Binding = "::"
    
    static var all: [Operator] = [.Assignment, .Lambda, .Binding]
    
    var matcher: Parser<Character, ()> {
        return string(rawValue).discard()
    }
}

let test = Operator.parse("::") // Optional(Operator.Binding)
```

Sometimes we'd like to lex more complex types, literal values for example. In these cases, we'd like to manually conform our type to `Parsable` by defining a static member `parser` that will transform valid input into an instance of our type.
```swift
enum LiteralValue: Parsable {
    case StringLiteral(String)
    case IntegerLiteral(Int)
    
    static var parser = coalesce(
        between(character("\""), parse: any()).stringify().map(LiteralValue.StringLiteral),
        
    )
}

let testString  = LiteralValue.parse("\"hey\"") // Optional(LiteralValue.StringLiteral("hey"))
let testInteger = LiteralValue.parse("-123")    // Optional(LiteralValue.IntegerLiteral(-123))
```

## Parsing
