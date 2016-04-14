//
//  OperatorSpecification.swift
//  Parsley
//
//  Created by Jaden Geller on 4/8/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct OperatorSpecification<Symbol: Hashable> {
    public var declarations: [OperatorDeclaration<Symbol>]
    
    public init(declarations: [OperatorDeclaration<Symbol>]) {
        self.declarations = declarations
    }
}

extension OperatorSpecification {
    public var symbols: [Symbol] {
        return declarations.map{ $0.symbol }
    }
}

extension OperatorSpecification {
    /// Orders the operators by descending precedence, grouping those of similiar precedence,
    /// and then further grouping by associativity.
    internal var descendingPrecedenceTieredInfixDeclarations: [[Associativity : [Symbol]]] {
        return declarations
            .groupSort{ $0.properties.precedence > $1.properties.precedence }
            .map{ $0.grouping(member: { $0.symbol }, by: { $0.properties.associativity }) }
    }
}

// MARK: Helpers

extension SequenceType {
    /// Sorts the elements, grouping those that are ordered the same.
    internal func groupSort(@noescape isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> [[Generator.Element]] {
        var grouped: [[Generator.Element]] = []
        var similiar: [Generator.Element] = []
        for element in sort(isOrderedBefore) {
            guard let check = similiar.first else {
                similiar.append(element)
                continue
            }
            
            assert(!isOrderedBefore(element, check))
            if isOrderedBefore(check, element) { // Different
                grouped.append(similiar)
                similiar = [element]
            } else { // Equal
                similiar.append(element)
            }
        }
        grouped.append(similiar)
        return grouped
    }
}

extension SequenceType {
    /// Groups values into a dictionary that share the computed key.
    internal func grouping<Key, Value>(member transform: Generator.Element -> Value, by key: Generator.Element -> Key) -> [Key : [Value]] {
        var result: [Key : [Value]] = [:]
        forEach { element in
            result[key(element)] = (result[key(element)] ?? []) + [transform(element)]
        }
        return result
    }
}
