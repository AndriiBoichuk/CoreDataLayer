//
//  SortDescriptors.swift
//
//  Created by Andrii Boichuk on 02.04.2024.
//

import Foundation

public final class SortDescriptor<Entity: ManagedObject> {
    public let rawValue: NSSortDescriptor
    public let key: String
    public let isAscending: Bool
    
    public init(rawValue: NSSortDescriptor) {
        if let key = rawValue.key,
           let attribute = Entity.entity().attributesByName.first(where: { $0.key == key }),
           attribute.value.attributeType == .stringAttributeType {
            let comparisonOptions = Config.defaultComparisonOptions
            let selector: Selector?

            // recreate sort descriptor using comparison options
            if comparisonOptions.contains(.caseInsensitive) && comparisonOptions.contains(.diacriticInsensitive) {
                selector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
            }
            else if comparisonOptions.contains(.caseInsensitive) {
                selector = #selector(NSString.caseInsensitiveCompare(_:))
            }
            else if comparisonOptions.contains(.diacriticInsensitive) {
                selector = #selector(NSString.localizedCompare(_:))
            }
            else {
                selector = nil
            }

            self.rawValue = NSSortDescriptor(key: rawValue.key, ascending: rawValue.ascending, selector: selector)
        }
        else {
            self.rawValue = rawValue
        }

        if let rawValueKey = self.rawValue.key {
            self.key = rawValueKey
        } else {
            #if DEBUG
            fatalError("No Key Profided")
            #else
            self.key = "NO KEY"
            #endif
        }
        self.isAscending = self.rawValue.ascending
    }
    
    public convenience init(key: String, isAscending: Bool) {
        self.init(rawValue: NSSortDescriptor(key: key, ascending: isAscending))
    }
    
    public convenience init<Value>(keyPath: KeyPath<Entity, Value>, isAscending: Bool) {
        self.init(rawValue: NSSortDescriptor(keyPath: keyPath, ascending: isAscending))
    }
}

// MARK: - Static Properties

public extension SortDescriptor {
    static func ascending(_ key: String) -> SortDescriptor<Entity> {
        SortDescriptor(key: key, isAscending: true)
    }
    
    static func ascending<Value>(_ keyPath: KeyPath<Entity, Value>) -> SortDescriptor<Entity> {
        SortDescriptor(keyPath: keyPath, isAscending: true)
    }
    
    static func descending(_ key: String) -> SortDescriptor<Entity> {
        SortDescriptor(key: key, isAscending: false)
    }
    
    static func descending<Value>(_ keyPath: KeyPath<Entity, Value>) -> SortDescriptor<Entity> {
        SortDescriptor(keyPath: keyPath, isAscending: false)
    }
}
