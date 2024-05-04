//
//  Predicate.swift
//
//  Created by Andrii Boichuk on 02.04.2024.
//

import Foundation

public class Predicate<Entity: ManagedObject> {
    public let rawValue: NSPredicate
    
    public init(rawValue: NSPredicate) {
        self.rawValue = rawValue
    }
    
    public convenience init(value: Bool) {
        self.init(rawValue: NSPredicate(value: value))
    }
    
    public convenience init(format predicateFormat: String, argumentArray arguments: [Any]?) {
        self.init(rawValue: NSPredicate(format: predicateFormat, argumentArray: arguments))
    }


    public convenience init(format predicateFormat: String, arguments argList: CVaListPointer) {
        self.init(rawValue: NSPredicate(format: predicateFormat, arguments: argList))
    }
}

// MARK: - ComparisonPredicate

public final class ComparisonPredicate<Entity: ManagedObject>: Predicate<Entity> {

    public typealias Modifier = NSComparisonPredicate.Modifier
    public typealias Operator = NSComparisonPredicate.Operator
    public typealias Options = NSComparisonPredicate.Options

    public let leftExpression: NSExpression
    public let rightExpression: NSExpression

    public let modifier: Modifier
    public let operatorType: Operator

    public let options: Options

    public init(leftExpression left: Expression, 
                rightExpression right: Expression,
                modifier: Modifier,
                type operatorType: Operator,
                options: Options = []) {

        self.leftExpression = left
        self.rightExpression = right
        self.modifier = modifier
        self.operatorType = operatorType
        self.options = options

        let predicate = NSComparisonPredicate(
            leftExpression: self.leftExpression,
            rightExpression: self.rightExpression,
            modifier: self.modifier,
            type: self.operatorType,
            options: self.options
        )

        super.init(rawValue: predicate)
    }

}

// MARK: - CompoundPredicate

public final class CompoundPredicate<Entity: ManagedObject>: Predicate<Entity> {

    public typealias LogicalType = NSCompoundPredicate.LogicalType

    public let type: LogicalType
    public let subpredicates: [Predicate<Entity>]

    public init(type: LogicalType, subpredicates: [Predicate<Entity>]) {
        self.type = type
        self.subpredicates = subpredicates

        let predicate = NSCompoundPredicate(type: self.type, subpredicates: self.subpredicates.map { $0.rawValue })

        super.init(rawValue: predicate)
    }

    public convenience init(andPredicateWithSubpredicates subpredicates: [Predicate<Entity>]) {
        self.init(type: .and, subpredicates: subpredicates)
    }

    public convenience init(orPredicateWithSubpredicates subpredicates: [Predicate<Entity>]) {
        self.init(type: .or, subpredicates: subpredicates)
    }

    public convenience init(notPredicateWithSubpredicate predicate: Predicate<Entity>) {
        self.init(type: .not, subpredicates: [predicate])
    }

}

public func &&<Entity>(left: Predicate<Entity>, right: Predicate<Entity>) -> Predicate<Entity> {
    CompoundPredicate(type: .and, subpredicates: [left, right])
}

public func ||<Entity>(left: Predicate<Entity>, right: Predicate<Entity>) -> Predicate<Entity> {
    CompoundPredicate(type: .or, subpredicates: [left, right])
}

public prefix func !<Entity>(left: Predicate<Entity>) -> Predicate<Entity> {
    CompoundPredicate(type: .not, subpredicates: [left])
}
