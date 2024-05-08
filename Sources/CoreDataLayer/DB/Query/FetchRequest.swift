//
//  FetchRequest.swift
//
//  Created by Andrii Boichuk on 02.04.2024.
//

import Foundation
import CoreData

public final class FetchRequest<Entity: ManagedObject> {
    public var offset: Int = 0
    public var limit: Int = 0
    public fileprivate(set) var batchSize: Int = Config.defaultBatchSize
    
    public var predicate: Predicate<Entity>? = nil
    public var sortDescriptiors: [SortDescriptor<Entity>]? = nil
    
    public init() { }
    
    public func toRaw() throws -> NSFetchRequest<Entity> {
        guard let rawValue = Entity.fetchRequest() as? NSFetchRequest<Entity> else {
            throw FetchRequestError.invalidFetchRequestResult
        }
        
        rawValue.fetchLimit = self.limit
        rawValue.fetchOffset = self.offset
        rawValue.fetchBatchSize = (self.limit > 0 && self.batchSize > self.limit ? 0 : self.batchSize)
        
        rawValue.predicate = self.predicate?.rawValue
        rawValue.sortDescriptors = self.sortDescriptiors?.map { $0.rawValue }
        
        return rawValue
    }
}

public extension FetchRequest {
    func dropFirst(_ n: Int) -> FetchRequest<Entity> {
        let clone = self
        
        clone.offset = n
        
        return clone
    }
    
    func prefix(_ maxLength: Int) -> FetchRequest<Entity> {
        let clone = self
        
        clone.limit = maxLength
        
        return clone
    }
    
    func batchSize(_ batchSize: Int) -> FetchRequest<Entity> {
        let clone = self
        
        clone.batchSize = batchSize
        
        return clone
    }
}

// MARK: - Filtering

public extension FetchRequest {
    func filtered(_ predicate: Predicate<Entity>) -> FetchRequest<Entity> {
        let clone = self
        
        if let existingPredicate = clone.predicate {
            clone.predicate = CompoundPredicate<Entity>(andPredicateWithSubpredicates: [existingPredicate, predicate])
        } else {
            clone.predicate = predicate
        }
        
        return clone
    }
}

// MARK: - Sorting

public extension FetchRequest {
    func sorted(by sortDescriptor: SortDescriptor<Entity>) -> FetchRequest<Entity> {
        let clone = self
        
        if let existingSortDescriptors = clone.sortDescriptiors {
            clone.sortDescriptiors = existingSortDescriptors + [sortDescriptor]
        } else {
            clone.sortDescriptiors = [sortDescriptor]
        }
        
        return clone
    }
    
    func sorted(by sortDescriptors: [SortDescriptor<Entity>]) -> FetchRequest<Entity> {
        let clone = self
        
        if let existingSortDescriptors = clone.sortDescriptiors {
            clone.sortDescriptiors = existingSortDescriptors + sortDescriptors
        } else {
            clone.sortDescriptiors = sortDescriptors
        }
        
        return clone
    }
    
    func sorted(by sortDescriptors: SortDescriptor<Entity>...) -> FetchRequest<Entity> {
        let clone = self
        
        if let existingSortDescriptors = clone.sortDescriptiors {
            clone.sortDescriptiors = existingSortDescriptors + sortDescriptors
        } else {
            clone.sortDescriptiors = sortDescriptors
        }
        
        return clone
    }
}

enum FetchRequestError: Error {
    case invalidFetchRequestResult
}
