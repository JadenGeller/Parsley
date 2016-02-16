# Parsley

Parsley is a recursive descent parser combinator library that makes it simple to write complex, type-safe parsers in Swift.

## Lexing
It's super easy to define lexable types in Parsley! The simplest types to lex are those whose values can be enumerated and matched against the input. For example, if you'd like to lex a finite set of operators, your operator type can conform to `Matchable` and it will be automatically `Parsable`.

Conformance to `Matchable` simply requires a static member `all` listing all the possible values of that type and an instance member `matcher` that will only accept input that matches, throwing a `ParseError` otherwise.
```swift
enum OperatorSymbol: Character, Matchable {
    case Plus  = "+"
    case Minus = "-"

    static var all: [OperatorSymbol] = [.Plus, .Minus]
    
    var matcher: Parser<Character, ()> {
        return character(rawValue).discard()
    }
}

let testPlus  = OperatorSymbol.parse("+") // Optional(Operator.Plus)
let testMinus = OperatorSymbol.parse("-") // Optional(Operator.Minus)
```

Sometimes we'd like to lex more complex types, literal values for example. In these cases, we'd like to manually conform our type to `Parsable` by defining a static member `parser` that will transform valid input into an instance of our type.
```swift
enum LiteralValue: Parsable {
    case StringLiteral(String)
    case IntegerLiteral(Int)
    
    static var parser = coalesce(
        between(character("\""), parseFew: any()).stringify().map(LiteralValue.StringLiteral),
        prepend(within("+-").otherwise("+"), many1(digit)).stringify().map{ Int($0)! }.map(LiteralValue.IntegerLiteral)
    )
}

let testString  = LiteralValue.parse("\"hey\"") // Optional(LiteralValue.StringLiteral("hey"))
let testInteger = LiteralValue.parse("-123")    // Optional(LiteralValue.IntegerLiteral(-123))
```

Once we've defined our basic token types, we might want to define some union type that can hold each of the cases. This type itself ought to be `Parsable` since each of its cases refer to `Parsable` tokens.
```swift
enum Token: Parsable {
    case Value(LiteralValue)
    case Operator(OperatorSymbol)
   
    static var parser = coalesce(
        LiteralValue.parser.map(Token.Value),
        OperatorSymbol.parser.map(Token.Operator)
    )
}

let testTokens = try! tokens(Token.self).parse("532 - 11 + \"hello\" + -3")
// [
//  Token.Value(LiteralValue.IntegerLiteral(532)), 
//  Token.Operator(OperatorSymbol.Minus),
//  Token.Value(LiteralValue.IntegerLiteral(11)),
//  Token.Operator(OperatorSymbol.Plus),
//  Token.Value(LiteralValue.StringLiteral("hello")),
//  Token.Operator(OperatorSymbol.Plus),
//  Token.Value(LiteralValue.IntegerLiteral(-3))
// ]
```
Note that the order we `coalesce` the two parsers does have an impact on the result. If we had swapped the order, we would be unable to recognize negative integer literals since we'd always parse the minus sign as an operator first.

## Parsing
Once we've finished lexing the input, it's time to parse! Now, the dividing line between these two stages isn't quite as clear as one might expect (as is evident by the fact we talked about a `Parsable` protocol in the lexing section of this document)! The lexing stage ought not care about the recursive tree-like structure of the input. Instead, the lexing stage ought to emit a linear sequence of tokens that simplifies the parsing logic. For example, the lexer ought to deal with discarding (or handling) whitespace so the parser doesn't have to complicate its logic worrying about these cases.

# To be continued.
