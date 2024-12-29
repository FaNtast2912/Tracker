//
//  TrackerStore.swift
//  Tracker
//
//  Created by Maksim Zakharov on 23.12.2024.
//
import CoreData
import UIKit

private enum TrackerStoreError: Error {
    case decodingErrorInvalidColor
    case decodingErrorInvalidId
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidName
    case decodingErrorInvalidSchedule
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate)
}

final class TrackerStore: NSObject {
    // MARK: - Public Properties
    weak var delegate: TrackerStoreDelegate?
    // MARK: - Private Properties
    private let uiColorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category, ascending: true)
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
    private var trackers: [Tracker] {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let trackers = try? objects.map({ trackerCoreData in
                  try self.tracker(from: trackerCoreData)
              }) else {return [] }
        return trackers
    }
    // MARK: - Initializers
    convenience override init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    // MARK: - Overrides Methods

    // MARK: - Public Methods
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.id = tracker.id
        trackerCoreData.isEvent = tracker.isEvent
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSArray?
        save()
    }
    
    func convertTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.id = tracker.id
        trackerCoreData.isEvent = tracker.isEvent
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSArray?
        return trackerCoreData
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        guard let colorRaw = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let scheduleRaw = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        let isEvent = trackerCoreData.isEvent
        let color = uiColorMarshalling.color(from: colorRaw)
        let schedule = scheduleRaw as? [Int] ?? []
        return Tracker(
            name: name,
            id: id,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isEvent: isEvent
        )
    }
    // MARK: - Private Methods
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexesUpdate = insertedIndexes, let deletedIndexesUpdate = deletedIndexes, let updatedIndexesUpdate = updatedIndexes, let movedIndexesUpdate = movedIndexes else { return }
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexesUpdate,
                deletedIndexes: deletedIndexesUpdate,
                updatedIndexes: updatedIndexesUpdate,
                movedIndexes: movedIndexesUpdate
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
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
