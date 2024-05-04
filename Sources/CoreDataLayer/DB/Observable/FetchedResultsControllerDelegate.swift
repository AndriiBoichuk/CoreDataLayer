//
//  File.swift
//  
//
//  Created by Andrii Boichuk on 20.04.2024.
//

import Foundation
import CoreData
import UIKit

class FetchedResultsControllerDelegate<T: ManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    var observer: ((ObservableChange<T>) -> Void)?
    private var batchChanges: [CoreDataChange<T>] = []
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let object = anObject as? T, let row = indexPath?.row else {
            return
        }
        
        switch type {
        case .insert:
            batchChanges.append(.insert(row, object))
        case .delete:
            batchChanges.append(.delete(row, object))
        case .move, .update:
            batchChanges.append(.update(row, object))
        @unknown 
        default:
            assertionFailure("trying to handle unknown case \(type)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        batchChanges = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let deleted: [Int] = batchChanges.filter { $0.isDeletion }.map { $0.index() }
        let inserted: [(index: Int, element: T)] = batchChanges.filter { $0.isInsertion }.map { (index: $0.index(), element: $0.object()) }
        let updated: [(index: Int, element: T)] = batchChanges.filter { $0.isUpdate }.map { (index: $0.index(), element: $0.object()) }
        
        let objects: [T] = controller.fetchedObjects as? [T] ?? []
        
        let mappedChange: ObservableChange<T>.ModelChange =  (
            objects: objects,
            deletions: deleted,
            insertions: inserted,
            modifications: updated
        )
        if let observer {
            observer(.change(mappedChange))
        }
        batchChanges = []
    }
}
