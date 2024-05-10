//
//  CoreDataObservable.swift
//
//
//  Created by Andrii Boichuk on 20.04.2024.
//

import Foundation
import CoreData

public class CoreDataObservable<Entity: ManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    var observer: ((ObservableChange<Entity>) -> Void)?
    
    let fetchRequest: NSFetchRequest<Entity>
    let fetchedResultsController: NSFetchedResultsController<Entity>
    
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<Entity>
    
    init(fetchRequest: FetchRequest<Entity>, context: ManagedObjectContext) throws {
        self.fetchRequest = try fetchRequest.toRaw()
        fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()
        fetchedResultsController.delegate = self
        
//        super.init(request: fetchRequest)
    }
    
    public func observe(_ closure: @escaping (ObservableChange<Entity>) -> Void) {
        assert(observer == nil, "Observable can be observed only once")
        
        do {
            let initial = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            closure(.initial(initial))
            observer = closure
            
            fetchedResultsControllerDelegate.observer = { [weak self] (change: ObservableChange<Entity>) in
                guard let self, case .change(let change) = change else {
                    return
                }
                let changes: ObservableChange<Entity>.ModelChange = (
                    objects: change.objects,
                    deletions: change.deletions,
                    insertions: change.insertions,
                    modifications: change.modifications
                )
                self.observer?(.change(changes))
            }
            
            try fetchedResultsController.performFetch()
        } catch {
            closure(.error(error))
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("--- didChange")
    }
}
