//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Maksim Zakharov on 23.12.2024.
//
import CoreData
import UIKit

private enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidName
    case decodingErrorInvalidTrackers
    case decodingErrorInvalidTracker
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    
    var trackersCategories: [TrackerCategory] {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let trackers = try? objects.map({ trackerCoreData in
                  try self.trackerCategory(from: trackerCoreData)
              }) else {return [] }
        return trackers
    }
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Properties
    
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    // MARK: - Initializers
    
    convenience override init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        self.init(context: context)
        if !isCategoryExists("Закрепленные") {
            let pinned = TrackerCategory(name: "Закрепленные", trackers: [])
            try? addNewTrackerCategory(pinned)
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Overrides Methods
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    func addTrackerToCategory(_ tracker: Tracker, category name: String) {
        let categoryRaw = fetchedResultsController.fetchedObjects?.first(where: {$0.name == name} )
        try? trackerStore.addNewTracker(tracker)
        let trackerCoreData = trackerStore.convertTracker(from: tracker)
        categoryRaw?.addToTrackers(trackerCoreData)
        save()
    }
    func deleteTracker(_ tracker: Tracker, from category: String) {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let categoryToModify = categories.first,
               let trackers = categoryToModify.trackers?.allObjects as? [TrackerCoreData] {
                
                // Find and delete the specific tracker
                if let trackerToDelete = trackers.first(where: { $0.id == tracker.id }) {
                    context.delete(trackerToDelete)
                    save()
                }
            }
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = trackerCategory.name
        trackerCategoryCoreData.trackers = NSSet(array: trackerCategory.trackers)
        save()
    }
    
    func isCategoryExists(_ name: String) -> Bool {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let matchingCategories = try context.fetch(fetchRequest)
            return !matchingCategories.isEmpty
        } catch {
            print("Error checking category existence: \(error)")
            return false
        }
    }
    
    func trackerCategory(named name: String) throws -> TrackerCategory? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let categories = try context.fetch(fetchRequest)
            guard let firstCategory = categories.first else {
                fatalError("Category \(name) not found")
            }
            return try? trackerCategory(from: firstCategory)
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let categoryToDelete = categories.first {
                if let trackers = categoryToDelete.trackers?.allObjects as? [TrackerCoreData] {
                    let trackerRecordStore = TrackerRecordStore(context: context)
                    for trackerCoreData in trackers {
                        if let trackerId = trackerCoreData.id {
                            let records = trackerRecordStore.getRecords()
                            let relatedRecords = records.filter { $0.id == trackerId }
                            for record in relatedRecords {
                                try trackerRecordStore.removeTrackerRecord(record)
                            }
                        }
                        context.delete(trackerCoreData)
                    }
                }
                context.delete(categoryToDelete)
                try context.save()
            }
        } catch {
            print("Error deleting category: \(error)")
            throw error
        }
    }
    // MARK: - Private Methods

    private func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodingErrorInvalidName
        }
        guard let trackersRaw = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        var trackers: [Tracker] = []
        
        for trackerRaw in trackersRaw {
            guard let trackerRaw = trackerRaw as? TrackerCoreData else {
                throw TrackerCategoryStoreError.decodingErrorInvalidTracker
            }
            trackers.append(try trackerStore.tracker(from: trackerRaw))
        }
        
        return TrackerCategory(name: name, trackers: trackers)
    }
    
    private func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("\(error.localizedDescription) errors in \(#file): in function\(#function):")
                context.rollback()
            }
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //TO DO
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        //        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //TO DO UI refresh table view
        //        delegate?.store(
        //            self,
        //            didUpdate: TrackerCategoryStoreUpdate(
        //                insertedIndexes: insertedIndexes!,
        //                deletedIndexes: deletedIndexes!,
        //                updatedIndexes: updatedIndexes!,
        //                movedIndexes: movedIndexes!
        //            )
        //        )
        //        insertedIndexes = nil
        //        deletedIndexes = nil
        //        updatedIndexes = nil
        //        movedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath? ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}
