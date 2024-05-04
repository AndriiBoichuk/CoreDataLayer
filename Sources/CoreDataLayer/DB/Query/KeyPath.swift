//
//  KeyPath.swift
//
//  Created by Andrii Boichuk on 02.04.2024.
//

import Foundation

// .equalTo

public func ==<Entity: ManagedObject, Value: Equatable>(left: KeyPath<Entity, Value>, right: Value) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .equalTo,
        options: right.comparisonOptions
    )
}

public func ==<Entity: ManagedObject, Value: Equatable>(left: KeyPath<Entity, Optional<Value>>, right: Optional<Value>) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .equalTo,
        options: right?.comparisonOptions ?? []
    )
}

// .notEqualTo

public func !=<Entity: ManagedObject, Value: Equatable>(left: KeyPath<Entity, Value>, right: Value) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .notEqualTo,
        options: right.comparisonOptions
    )
}

public func !=<Entity: ManagedObject, Value: Equatable>(left: KeyPath<Entity, Optional<Value>>, right: Optional<Value>) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .notEqualTo,
        options: right?.comparisonOptions ?? []
    )
}

// .lessThan

public func <<Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Value>, right: Value) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .lessThan,
        options: right.comparisonOptions
    )
}

public func <<Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Optional<Value>>, right: Optional<Value>) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .lessThan,
        options: right?.comparisonOptions ?? []
    )
}

// .lessThanOrEqualTo

public func <=<Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Value>, right: Value) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .lessThanOrEqualTo,
        options: right.comparisonOptions
    )
}

public func <=<Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Optional<Value>>, right: Optional<Value>) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .lessThanOrEqualTo,
        options: right?.comparisonOptions ?? []
    )
}

// .greaterThan

public func ><Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Value>, right: Value) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .greaterThan,
        options: right.comparisonOptions
    )
}

public func ><Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Optional<Value>>, right: Optional<Value>) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .greaterThan,
        options: right?.comparisonOptions ?? []
    )
}

// .greaterThanOrEqualTo

public func >=<Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Value>, right: Value) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .greaterThanOrEqualTo,
        options: right.comparisonOptions
    )
}

public func >=<Entity: ManagedObject, Value: Comparable>(left: KeyPath<Entity, Optional<Value>>, right: Optional<Value>) -> ComparisonPredicate<Entity> {
    return ComparisonPredicate<Entity>(
        leftExpression: Expression(forKeyPath: left),
        rightExpression: Expression(forConstantValue: right),
        modifier: .direct,
        type: .greaterThanOrEqualTo,
        options: right?.comparisonOptions ?? []
    )}


// MARK: - KeyPath + Extension

extension KeyPath {
    var pathString: String {
        return self._kvcKeyPathString!
    }
}

// MARK: - Equatable + Extension

extension Equatable {
    fileprivate var comparisonOptions: ComparisonPredicate<ManagedObject>.Options {
        if self is String || self is NSString {
            return Config.defaultComparisonOptions
        }

        return []
    }
}
