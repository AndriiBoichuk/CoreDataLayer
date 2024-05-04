//
//  NSManagedObjectContext+Extension.swift
//
//  Created by Andrii Boichuk on 09.03.2024.
//

import CoreData

extension NSManagedObjectContext {
    func save(includingParent: Bool) throws {
        guard hasChanges else { return }
        
        try save()
        
        if includingParent, let parent {
            try parent.performAndWait {
                try parent.save(includingParent: true)
            }
        }
    }
}
