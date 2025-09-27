//
//  PersistenceController.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation
import CoreData

// Manages the app's database system
class PersistenceController {
    // One shared database manager for the whole app
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    // Sets up the database when the app starts
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cryptomania")
        
        // For testing - stores data in memory instead of on disk
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Loads the database and handles any errors
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Saves any changes to the database
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    // Creates a temporary database for app previews and testing
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data here if needed for previews
        return controller
    }()
}
