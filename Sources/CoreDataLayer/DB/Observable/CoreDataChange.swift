//
//  File.swift
//  
//
//  Created by Andrii Boichuk on 24.04.2024.
//

import Foundation

enum CoreDataChange<T> {
    case update(Int, T)
    case delete(Int, T)
    case insert(Int, T)
    
    func object() -> T {
        switch self {
        case .update(_, let object): return object
        case .delete(_, let object): return object
        case .insert(_, let object): return object
        }
    }
    
    func index() -> Int {
        switch self {
        case .update(let index, _): return index
        case .delete(let index, _): return index
        case .insert(let index, _): return index
        }
    }
    
    var isDeletion: Bool {
        switch self {
        case .delete: return true
        default: return false
        }
    }
    
    var isUpdate: Bool {
        switch self {
        case .update: return true
        default: return false
        }
    }
    
    var isInsertion: Bool {
        switch self {
        case .insert: return true
        default: return false
        }
    }
}
