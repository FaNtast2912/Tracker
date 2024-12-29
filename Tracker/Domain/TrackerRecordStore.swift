//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Maksim Zakharov on 23.12.2024.
//
import CoreData
import UIKit

private enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidDate
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Public Properties

    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
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
    
    func getRecords() -> [TrackerRecord] {
        try? fetchedResultsController.performFetch()
        guard let objects = fetchedResultsController.fetchedObjects,
              let records = try? objects.map({ try self.record(from: $0) })
        else { return [] }
        return records
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.id = trackerRecord.id
        save()
        try fetchedResultsController.performFetch()
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date == %@",
            trackerRecord.id as CVarArg,
            trackerRecord.date as CVarArg
        )
        
        let records = try context.fetch(fetchRequest)
        records.forEach { context.delete($0) }
        save()
        try fetchedResultsController.performFetch()
    }
    
    func recordExists(_ trackerRecord: TrackerRecord) throws -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date == %@",
            trackerRecord.id as CVarArg,
            trackerRecord.date as CVarArg
        )
        
        let count = try context.count(for: fetchRequest)
        return count > 0
    }
    
    // MARK: - Private Methods
    
    private func save() {
        if context.hasChanges {
            do {
                try context.save()
                try context.parent?.save()
            } catch {
                print("\(error.localizedDescription) errors in \(#file): in function\(#function):")
                context.rollback()
            }
        }
    }
    
    private func record(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidDate
        }
        
        guard let id = trackerRecordCoreData.id else {
            throw TrackerRecordStoreError.decodingErrorInvalidId
        }
        
        return TrackerRecord(id: id, date: date)
    }
}
