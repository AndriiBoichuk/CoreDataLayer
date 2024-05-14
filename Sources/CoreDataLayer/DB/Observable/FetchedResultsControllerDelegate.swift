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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let fetchedObjects = controller.fetchedObjects as? [T] {
            observer?(.change(fetchedObjects))
        }
    }
}
