//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Maksim Zakharov on 29.12.2024.
//
import CoreData

final class DataBaseStore {
    
    // MARK: - Public Properties
    static let shared = DataBaseStore()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Library")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Код для обработки ошибки
            }
        })
        return container
    }()
    // MARK: - Private Properties

    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                context.rollback()
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Private Methods
}
