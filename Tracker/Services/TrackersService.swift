//
//  Untitled.swift
//  Tracker
//
//  Created by Maksim Zakharov on 08.12.2024.
//

import UIKit

final class TrackersService {
    
    // MARK: - Public Properties
    
    static let shared = TrackersService()
    var trackerCategoryStore: TrackerCategoryStore {
            return _trackerCategoryStore
        }
    private let _trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    
    var visibleCategory: [TrackerCategory] = []
    var isStorageEmpty: Bool {
        guard let firstCategory = categories.first else { return true }
        return firstCategory.trackers.isEmpty
    }
    var visibleCount: Int { visibleCategory.count }
    var isVisibleTrackersEmpty: Bool {
        if visibleCategory.isEmpty {
            return true
        }
        if visibleCategory[0].trackers.isEmpty {
            return true
        } else {
            return false
        }
    }
    var categories : [TrackerCategory] {
        return trackerCategoryStore.trackersCategories
    }
    
    // MARK: - Private Properties
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Overrides Methods
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    func appendTrackerInVisibleTrackers(weekday: Int, from recordTrackers: [TrackerRecord], selectedDate: Date) {
        var trackers = [Tracker]()
        
        let records = trackerRecordStore.getRecords()
        
        for category in categories {
            for tracker in category.trackers {
                if tracker.isEvent {
                    let trackerRecords = records.filter { $0.id == tracker.id }
                    if trackerRecords.isEmpty {
                        trackers.append(tracker)
                    } else {
                        let hasRecordOnSelectedDate = trackerRecords.contains { record in
                            Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
                        }
                        if hasRecordOnSelectedDate {
                            trackers.append(tracker)
                        }
                    }
                } else {
                    for day in tracker.schedule {
                        if day == weekday {
                            trackers.append(tracker)
                        }
                    }
                }
            }
            if !trackers.isEmpty {
                let categoryWithVisibleTrackers = TrackerCategory(name: category.name, trackers: trackers)
                visibleCategory.append(categoryWithVisibleTrackers)
            }
            trackers = []
        }
    }
    
    func clearVisibleTrackers() {
        visibleCategory.removeAll()
    }
    func createNewTracker(tracker: Tracker, category: String) {
        trackerCategoryStore.addTrackerToCategory(tracker, category: category)
    }
    func createNewCategory(newCategory: TrackerCategory) {
        try? trackerCategoryStore.addNewTrackerCategory(newCategory)
    }
    func checkIsCategoryEmpty() -> Bool {
        categories.isEmpty
    }
    func getTrackerDetails(section: Int, item: Int) -> Tracker {
        visibleCategory[section].trackers[item]
    }
    func countOfItemsInSection(section: Int) -> Int {
        visibleCategory[section].trackers.count
    }
    func titleForSection(section: Int) -> String {
        visibleCategory[section].name
    }
    func addTrackerRecord(_ id: UUID, date: Date) {
        let trackerRecord = TrackerRecord(id: id, date: date)
        try? trackerRecordStore.addNewTrackerRecord(trackerRecord)
    }
    
    func removeTrackerRecord(_ id: UUID, date: Date) {
        let trackerRecord = TrackerRecord(id: id, date: date)
        try? trackerRecordStore.removeTrackerRecord(trackerRecord)
    }
    
    func isTrackerRecordExist(_ id: UUID, date: Date) -> Bool {
        let trackerRecord = TrackerRecord(id: id, date: date)
        return (try? trackerRecordStore.recordExists(trackerRecord)) ?? false
    }
    
    func getRecords() -> [TrackerRecord] {
        return trackerRecordStore.getRecords()
    }
    
    func isCategoryExist(_ name: String) -> Bool {
        trackerCategoryStore.isCategoryExists(name)
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
       try? trackerCategoryStore.deleteCategory(category)
    }
    
    // MARK: - Private Methods
    
}
