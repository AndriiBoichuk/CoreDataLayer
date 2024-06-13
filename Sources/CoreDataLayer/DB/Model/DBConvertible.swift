//
//  DBMapable.swift
//
//  Created by Andrii Boichuk on 21.03.2024.
//

import Foundation


public protocol ToDBConvetible {
    @discardableResult
    func object(in context: ManagedObjectContext) -> ManagedObject
}

public protocol FromDBConvetible {
    init?(with object: ManagedObject)
}

public typealias DBConvertible = ToDBConvetible & FromDBConvetible
