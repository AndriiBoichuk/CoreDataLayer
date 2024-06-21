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
        fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = fetchedResultsControllerDelegate
        
        super.init(request: fetchRequest)
    }
    
    deinit {
        print("--- deinit")
    }
    
    override func observe(_ closure: @escaping (ObservableChange<Entity>) -> Void) {
        assert(observer == nil, "Observable can be observed only once")
        
        do {
            let initial = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            closure(.initial(initial))
            observer = closure
            
            fetchedResultsControllerDelegate.observer = { [weak self] (change: ObservableChange<Entity>) in
                guard let self, case .change(let objects) = change else {
                    return
                }
                self.observer?(.change(objects))
            }
            
            try fetchedResultsController.performFetch()
        } catch {
            closure(.error(error))
        }
    }
}
