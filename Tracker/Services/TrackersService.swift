//
//  Untitled.swift
//  Tracker
//
//  Created by Maksim Zakharov on 08.12.2024.
//

import UIKit

final class TrackersService {
    
    // MARK: - Public Properties
    let trackerCategoryStore = TrackerCategoryStore()
    static let shared = TrackersService()
    var visibleCategory: [TrackerCategory] = []
    var isStorageEmpty: Bool {
        return categories.isEmpty
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
    var isFiltering: Bool = false
    
    // MARK: - Private Properties
    private var filterState: FilterState = .all
    private var filteredTrackers: [TrackerCategory] = []
    private var trackerRecordStore = TrackerRecordStore()
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Overrides Methods
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    func getVisibleCategories(for selectedDate: Date, and state: FilterState) {
        filterState = state
        clearVisibleTrackers()
        let weekday = convertWeekDay(weekDay: calendar.component(.weekday, from: selectedDate))
        let records = trackerRecordStore.getRecords()
        for category in categories {
            if let visibleTrackers = getVisibleTrackers(
                in: category,
                weekday: weekday,
                selectedDate: selectedDate,
                records: records,
                state: state
            ) {
                visibleCategory.append(visibleTrackers)
            }
        }
        sortVisibleCategory()
    }
    
    func clearVisibleTrackers() {
        visibleCategory.removeAll()
    }
    func createNewTracker(tracker: Tracker, category: String) {
        trackerCategoryStore.addTrackerToCategory(tracker, category: category)
    }
    func deleteTracker(_ tracker: Tracker) throws {
        let records = trackerRecordStore.getRecords()
        let relatedRecords = records.filter { $0.id == tracker.id }
        for record in relatedRecords {
            try trackerRecordStore.removeTrackerRecord(record)
        }
        
        guard let category = categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) else {
            return
        }
        trackerCategoryStore.deleteTracker(tracker, from: category.name)
        
        if tracker.isPinned {
            trackerCategoryStore.deleteTracker(tracker, from: "Закрепленные")
        }
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
    
    func filterTrackersByName(_ query: String, date: Date) {
        clearVisibleTrackers()
        var trackers = [Tracker]()
        let weekday = convertWeekDay(weekDay: calendar.component(.weekday, from: date))
        for category in categories {
            for tracker in category.trackers {
                if category.name == "Закрепленные", tracker.isPinned == true {
                    trackers.append(tracker)
                } else {
                    if tracker.name.lowercased().contains(query.lowercased()) {
                        if tracker.isEvent {
                            trackers.append(tracker)
                        } else if tracker.schedule.contains(weekday){
                            trackers.append(tracker)
                        }
                    }
                }
            }
            if !trackers.isEmpty {
                let categoryWithVisibleTrackers = TrackerCategory(name: category.name, trackers: trackers)
                visibleCategory.append(categoryWithVisibleTrackers)
            }
            trackers.removeAll()
        }
        sortVisibleCategory()
    }
    // MARK: - Private Methods
    private func getVisibleTrackers(
        in category: TrackerCategory,
        weekday: Int,
        selectedDate: Date,
        records: [TrackerRecord],
        state: FilterState
    ) -> TrackerCategory? {
        let visibleTrackers = category.trackers.filter { tracker in
            
            if isPinnedInPinnedCategory(tracker: tracker, categoryName: category.name) {
                return true
            }
            
            if tracker.isPinned {
                return false
            }
            
            return tracker.isEvent
            ? isVisibleEvent(tracker: tracker, selectedDate: selectedDate, records: records, state: state)
            : isVisibleRegularTracker(tracker: tracker, selectedDate: selectedDate, state: state, records: records)
            
        }
        
        return visibleTrackers.isEmpty ? nil : TrackerCategory(
            name: category.name,
            trackers: visibleTrackers
        )
    }
    
    private func isPinnedInPinnedCategory(tracker: Tracker, categoryName: String) -> Bool {
        categoryName == "Закрепленные" && tracker.isPinned
    }
    
    private func isVisibleEvent(
        tracker: Tracker,
        selectedDate: Date,
        records: [TrackerRecord],
        state: FilterState
    ) -> Bool {
        let trackerRecords = records.filter { $0.id == tracker.id }
        
        if !trackerRecords.isEmpty, state == .uncomplete {
            return false
        } else if trackerRecords.isEmpty, state == .complete {
            return false
        } else if trackerRecords.isEmpty {
            return true
        }
        
        return trackerRecords.contains { record in
            calendar.isDate(record.date, inSameDayAs: selectedDate)
        }
    }
    
    private func isVisibleRegularTracker(tracker: Tracker, selectedDate: Date, state: FilterState, records: [TrackerRecord]) -> Bool {
        let trackerRecords = records.filter { $0.id == tracker.id }
        let weekday = convertWeekDay(weekDay: calendar.component(.weekday, from: selectedDate))
        
        if !trackerRecords.isEmpty, state == .uncomplete {
            return false
        } else if !trackerRecords.isEmpty, state == .complete {
            return trackerRecords.contains { record in
                calendar.isDate(record.date, inSameDayAs: selectedDate)
            }
        } else if trackerRecords.isEmpty, state == .complete {
            return false
        }
        
        return tracker.schedule.contains(weekday)
    }

    private func convertWeekDay(weekDay: Int) -> Int {
        switch weekDay {
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 3
        case 5:
            return 4
        case 6:
            return 5
        case 7:
            return 6
        case 1:
            return 7
        default:
            print("unexpected week day")
        }
        return 0
    }
    
    private func sortVisibleCategory() {
        visibleCategory.sort { firstCategory, secondCategory in
            if firstCategory.name == "Закрепленные" {
                firstCategory.name > secondCategory.name
            } else {
                secondCategory.name > firstCategory.name
            }
        }
    }
}
