//
//  DBService.swift
//
//  Created by Andrii Boichuk on 19.02.2024.
//

import CoreData

public final class DBService {
    private let container: NSPersistentContainer
    
    public init(modelName: String, inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: modelName)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - CoreData Stack
    
    fileprivate lazy var viewContext: NSManagedObjectContext = {
        container.viewContext
    }()
    
    fileprivate lazy var readContext: NSManagedObjectContext = {
        container.newBackgroundContext()
    }()
    
    fileprivate lazy var writeContext: NSManagedObjectContext = {
        container.newBackgroundContext()
    }()
}

// MARK: - Read

private extension DBService {
    func performReadTask<T>(closure: @escaping (NSManagedObjectContext) throws -> (T)) async throws -> T{
        let context = readContext
        return try await context.perform {
            try closure(context)
        }
    }
}


// MARK: - Write

private extension DBService {
    func performWriteTask(_ closure: @escaping (NSManagedObjectContext, (() throws -> ())) throws -> ()) async throws {
        let context = viewContext
        try await context.perform {
            try closure(context) {
                try context.save()
            }
        }
    }
}

// MARK: - Public Methods

// MARK: Get Methods
public extension DBService {
    func execute(fetchRequest: FetchRequest<some ManagedObject>) async throws -> [some ManagedObject] {
        try await performReadTask { context in
            try context.fetch(fetchRequest.toRaw())
        }
    }
    
    func executeConvetible<T: FromDBConvetible>(fetchRequest: FetchRequest<some ManagedObject>) async throws -> [T] {
        try await performReadTask { context in
            let fetchRequestRaw: NSFetchRequest<some ManagedObject> = try fetchRequest.toRaw()
            let objects: [some ManagedObject] = try context.fetch(fetchRequestRaw)
            return objects.compactMap { [weak self] object in
                self?.map(object: object, to: T.self)
            }
        }
    }
    
    func count(fetchRequest: FetchRequest<some ManagedObject>) async throws -> Int {
        try await performReadTask { context in
            try context.count(for: fetchRequest.toRaw())
        }
    }
    
    func first(fetchRequest: FetchRequest<some ManagedObject>) async throws -> (some ManagedObject)? {
        try await performReadTask { context in
            fetchRequest.limit = 1
            return try context.fetch(fetchRequest.toRaw()).first
        }
    }
    
    func firstConvetible<T: FromDBConvetible>(fetchRequest: FetchRequest<some ManagedObject>) async throws -> T? {
        try await performReadTask { [weak self] context in
            guard let self else {
                throw DBServiceError.selfDeallocated
            }
            
            fetchRequest.limit = 1
            
            if let object: some ManagedObject = try context.fetch(fetchRequest.toRaw()).first, let mappedObject = self.map(object: object, to: T.self) {
                return mappedObject
            } else {
                return nil
            }
        }
    }
    
    func firstOrEmptyNew(fetchRequest: FetchRequest<some ManagedObject>) async throws -> some ManagedObject {
        try await performReadTask { [weak self] context in
            guard let self else {
                throw DBServiceError.selfDeallocated
            }
            
            fetchRequest.limit = 1
            
            guard let existingEntity: some ManagedObject = try context.fetch(fetchRequest.toRaw()).first else {
                return new(in: context)
            }
            return existingEntity
        }
    }
}

// MARK: Insert Methods

public extension DBService {
    func insert<T: ToDBConvetible>(model: T) async throws {
        try await performWriteTask { context, saveAction in
            model.object(in: context)
            try saveAction()
        }
    }
}

// MARK: Observable

public extension DBService {
    func observable<T: ManagedObject>(_ request: FetchRequest<T>) throws -> RequestObservable<T> {
        try CoreDataObservable(fetchRequest: request, context: viewContext)
    }
}

// MARK: - Private Methods

private extension DBService {
    func new<Entity: ManagedObject>(in context: NSManagedObjectContext) -> Entity {
        Entity(context: context)
    }
    
    func map<Entity: ManagedObject, T: FromDBConvetible>(object: Entity, to Type: T.Type) -> T? {
        .init(with: object)
    }
}

public enum DBServiceError: Error {
    case selfDeallocated
}
