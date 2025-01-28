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
                if category.name == "Закрепленные", tracker.isPinned == true {
                    trackers.append(tracker)
                } else {
                    if tracker.isEvent, tracker.isPinned == false {
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
                    } else if tracker.isPinned == false {
                        for day in tracker.schedule {
                            if day == weekday {
                                trackers.append(tracker)
                            }
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
        
        visibleCategory.sort { firstCategory, secondCategory in
            if firstCategory.name == "Закрепленные" {
                firstCategory.name > secondCategory.name
            } else {
                secondCategory.name > firstCategory.name
            }
        }
        
    }
    
    func filterTrackers(by state: FilterState) {
        switch state {
        case.all:
            appendAllTrackerInVisibleCategory()
        case.complete:
            appendCompletedTrackerInVisibleCategory()
        case.today:
            break
        case.uncomplete:
            appendUncompletedTrackerInVisibleCategory()
        }
    }
    
    private func appendAllTrackerInVisibleCategory() {
        clearVisibleTrackers()
        var trackers = [Tracker]()
        
        for category in categories {
            for tracker in category.trackers {
                trackers.append(tracker)
            }
            
            if !trackers.isEmpty {
                let categoryWithVisibleTrackers = TrackerCategory(name: category.name, trackers: trackers)
                visibleCategory.append(categoryWithVisibleTrackers)
            }
            trackers = []
        }
        
        visibleCategory.sort { firstCategory, secondCategory in
            if firstCategory.name == "Закрепленные" {
                firstCategory.name > secondCategory.name
            } else {
                secondCategory.name > firstCategory.name
            }
        }
    }
    
    private func appendCompletedTrackerInVisibleCategory() {
        clearVisibleTrackers()
        var trackers = [Tracker]()
        let records = trackerRecordStore.getRecords()
        for category in categories {
            for tracker in category.trackers {
                let trackerRecords = records.filter { $0.id == tracker.id }
                if !trackerRecords.isEmpty {
                    trackers.append(tracker)
                }
            }
            
            if !trackers.isEmpty {
                let categoryWithVisibleTrackers = TrackerCategory(name: category.name, trackers: trackers)
                visibleCategory.append(categoryWithVisibleTrackers)
            }
            trackers = []
        }
        
        visibleCategory.sort { firstCategory, secondCategory in
            if firstCategory.name == "Закрепленные" {
                firstCategory.name > secondCategory.name
            } else {
                secondCategory.name > firstCategory.name
            }
        }
    }
    
    private func appendUncompletedTrackerInVisibleCategory() {
        clearVisibleTrackers()
        var trackers = [Tracker]()
        let records = trackerRecordStore.getRecords()
        for category in categories {
            for tracker in category.trackers {
                let trackerRecords = records.filter { $0.id != tracker.id }
                if !trackerRecords.isEmpty {
                    trackers.append(tracker)
                }
            }
            
            if !trackers.isEmpty {
                let categoryWithVisibleTrackers = TrackerCategory(name: category.name, trackers: trackers)
                visibleCategory.append(categoryWithVisibleTrackers)
            }
            trackers = []
        }
        
        visibleCategory.sort { firstCategory, secondCategory in
            if firstCategory.name == "Закрепленные" {
                firstCategory.name > secondCategory.name
            } else {
                secondCategory.name > firstCategory.name
            }
        }
    }
    
    func clearVisibleTrackers() {
        visibleCategory.removeAll()
    }
    func createNewTracker(tracker: Tracker, category: String) {
        trackerCategoryStore.addTrackerToCategory(tracker, category: category)
    }
    func deleteTracker(_ tracker: Tracker) throws {
        guard let category = categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) else {
            return
        }
        trackerCategoryStore.deleteTracker(tracker, from: category.name)
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
    
    func pinTracker(_ tracker: Tracker) {
        let pinnedTracker = Tracker(
            name: tracker.name,
            id: tracker.id,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            isEvent: tracker.isEvent,
            isPinned: true
        )
        guard let currentCategory = categories.first(where: { category in
            category.name != "Закрепленные" && category.trackers.contains(where: { $0.id == tracker.id })
        }) else { return }
        trackerCategoryStore.deleteTracker(tracker, from: currentCategory.name)
        createNewTracker(tracker: pinnedTracker, category: currentCategory.name)
        createNewTracker(tracker: pinnedTracker, category: "Закрепленные")
    }
    
    func unpinTracker(_ tracker: Tracker) {
        let unpinnedTracker = Tracker(
            name: tracker.name,
            id: tracker.id,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            isEvent: tracker.isEvent,
            isPinned: false
        )
        guard let currentCategory = categories.first(where: { category in
            category.name != "Закрепленные" && category.trackers.contains(where: { $0.id == tracker.id })
        }) else { return }
        trackerCategoryStore.deleteTracker(tracker, from: "Закрепленные")
        trackerCategoryStore.deleteTracker(tracker, from: currentCategory.name)
        createNewTracker(tracker: unpinnedTracker, category: currentCategory.name)
    }
    
    // MARK: - Private Methods
    
}
