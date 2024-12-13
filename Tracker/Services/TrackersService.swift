//
//  Untitled.swift
//  Tracker
//
//  Created by Maksim Zakharov on 08.12.2024.
//

import UIKit

final class TrackersService {
    // MARK: - IB Outlets
    
    // MARK: - Public Properties
    static let shared = TrackersService()
    var visibleCategory: [TrackerCategory] = []
    var isStorageEmpty: Bool { categories[0].trackers.isEmpty }
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
    var categories : [TrackerCategory] = [TrackerCategory(
        name: "Важное",
        trackers: [
            Tracker(
                name: "Бить баклуши",
                id: UUID(),
                color: UIColor.red,
                emoji: "🍺",
                schedule: [.monday,
                           .tuesday,
                           .wednesday,
                           .thursday,
                           .friday,
                           .saturday,
                           .sunday]
            ),
            Tracker(
                name: "Изучаем SwiftUI",
                id: UUID(),
                color: UIColor.blue,
                emoji: "🧑‍💻",
                schedule: [.monday,
                           .tuesday,
                           .wednesday,
                           .thursday,
                           .friday,
                           .saturday,
                           .sunday]
            ),
            Tracker(
                name: "Провести воркшоп для 27-й когорты",
                id: UUID(),
                color: UIColor.green,
                emoji: "👨‍🏫",
                schedule: [.tuesday]
            ),
            Tracker(
                name: "Поиск работы",
                id: UUID(),
                color: UIColor.systemYellow,
                emoji: "🔎",
                schedule: [.monday,
                           .tuesday,
                           .wednesday,
                           .thursday]
            )
        ]
    )]
    // MARK: - Private Properties
    
    // MARK: - Initializers
    private init() { }
    // MARK: - Overrides Methods
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    func appendTrackerInVisibleTrackers(weekday: Int) {
        var trackers = [Tracker]()
        let weekDays: Weekday = convertNumberToWeekDay(number: weekday)
        for tracker in categories.first!.trackers {
            for day in tracker.schedule {
                if day == weekDays {
                    trackers.append(tracker)
                }
            }
        }
        let categoryWithVisibleTrackers = TrackerCategory(name: categories.first!.name, trackers: trackers)
        visibleCategory.append(categoryWithVisibleTrackers)
    }
    func clearVisibleTrackers() {
        visibleCategory.removeAll()
    }
    func createNewTracker(tracker: Tracker) {
        var trackers: [Tracker] = []
        guard let list = categories.first else {return}
        for tracker in list.trackers{
            trackers.append(tracker)
        }
        trackers.append(tracker)
        categories = [TrackerCategory(name: "Важное", trackers: trackers)]
    }
    func createNewCategory(newCategoty: TrackerCategory) {
        // TO DO
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
    // MARK: - Private Methods
    private func convertNumberToWeekDay(number: Int) -> Weekday {
        var day: Weekday = .monday
        switch number {
        case 2:
            day = .monday
        case 3:
            day = .tuesday
        case 4:
            day = .wednesday
        case 5:
            day = .thursday
        case 6:
            day = .friday
        case 7:
            day = .saturday
        case 1:
            day = .sunday
        default:
            break
        }
        return day
    }
}
