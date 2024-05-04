//
//  CoreDataObservable.swift
//
//
//  Created by Andrii Boichuk on 20.04.2024.
//

import Foundation
import CoreData

class CoreDataObservable<Entity: ManagedObject>: RequestObservable<Entity> {
    var observer: ((ObservableChange<Entity>) -> Void)?
    
    let fetchRequest: NSFetchRequest<Entity>
    let fetchedResultsController: NSFetchedResultsController<Entity>
    
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<Entity>
    
    init(fetchRequest: FetchRequest<Entity>, context: ManagedObjectContext) throws {
        self.fetchRequest = try fetchRequest.toRaw()
        self.fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.fetchedResultsController.delegate = self.fetchedResultsControllerDelegate
        
        super.init(request: fetchRequest)
    }
    
    override func observe(_ closure: @escaping (ObservableChange<Entity>) -> Void) {
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
}
