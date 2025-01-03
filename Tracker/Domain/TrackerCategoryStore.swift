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
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        if trackersCategories.isEmpty {
            try? addNewTrackerCategory(TrackerCategory(name: "Важное", trackers: []))
        }
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
    // MARK: - Private Methods
    
    private func addNewTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = trackerCategory.name
        trackerCategoryCoreData.trackers = NSSet(array: trackerCategory.trackers)
        save()
    }
    
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
