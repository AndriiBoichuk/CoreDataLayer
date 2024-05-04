//
//  File.swift
//  
//
//  Created by Andrii Boichuk on 20.04.2024.
//

import Foundation
import CoreData

public enum ObservableChange<T: ManagedObject> {
    public typealias ModelChange = (
        objects: [T],
        deletions: [Int],
        insertions: [(index: Int, element: T)],
        modifications: [(index: Int, element: T)]
    )
    
    case initial([T])
    case change(ModelChange)
    case error(Error)
}

public class RequestObservable<T: ManagedObject> {
    let request: FetchRequest<T>
    
    init(request: FetchRequest<T>) {
        self.request = request
    }
    
    /// Starts observing with a given fetch request.
    ///
    /// - Parameter closure: gets called once any changes in database are occurred.
    /// - Warning: You cannot call the method only if you don't observe it now.
    public func observe(_ closure: @escaping (ObservableChange<T>) -> Void) {
        assertionFailure("The observe method must be overriden")
    }
}
