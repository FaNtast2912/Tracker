//
//  Untitled.swift
//  Tracker
//
//  Created by Maksim Zakharov on 09.12.2024.
//
final class Schedule {
    // MARK: - Public Properties
    var isAllSelected: Bool {
        selectedWeekDays.count == 7
    }
    var isEmpty: Bool {
        selectedWeekDays.count == 0
    }
    var selectedDaysOfWeek: [Weekday] {
        var arr = [Weekday]()
        for key in selectedWeekDays.keys.sorted() {
            var day: Weekday = .monday
            switch key {
            case 0:
                day = .monday
            case 1:
                day = .tuesday
            case 2:
                day = .wednesday
            case 3:
                day = .thursday
            case 4:
                day = .friday
            case 5:
                day = .saturday
            case 6:
                day = .sunday
            default:
                break
            }
            arr.append(day)
        }
        return arr
    }
    // MARK: - Private Properties
    private var selectedWeekDays: [Int : Weekday] = [:]
    // MARK: - Initializers

    // MARK: - Overrides Methods

    // MARK: - IB Actions

    // MARK: - Public Methods
    func getStringFromWeekDays(weekDays: [Weekday])  -> String {
        let count = weekDays.count
        let isAllSelected = count == 7
        var resultArr: [String] = []
        for numberOfDay in 0...6 {
            switch numberOfDay {
            case 0:
                resultArr.append("Пн")
            case 1:
                resultArr.append("Вт")
            case 2:
                resultArr.append("Ср")
            case 3:
                resultArr.append("Чт")
            case 4:
                resultArr.append("Пт")
            case 5:
                resultArr.append("Cб")
            case 6:
                resultArr.append("Вск")
            default:
                resultArr.append("")
            }
        }
        return isAllSelected ? "Каждый день" : resultArr.joined(separator: ",")
    }
    func receiveWeekDay(dayOfWeek: Int) {
        if let _ = selectedWeekDays[dayOfWeek] {
            removeWeekDay(dayOfWeek: dayOfWeek)
        } else {
            addWeekDay(dayOfWeek: dayOfWeek)
        }
    }
    // MARK: - Private Methods
    private func addWeekDay(dayOfWeek: Int) {
        selectedWeekDays[dayOfWeek] = convertNumberToWeekDay(number: dayOfWeek)
    }
    private func removeWeekDay(dayOfWeek: Int) {
        selectedWeekDays.removeValue(forKey: dayOfWeek)
    }
    private func convertNumberToWeekDay(number: Int) -> Weekday {
        var day: Weekday = .monday
        switch number {
        case 0:
            day = .monday
        case 1:
            day = .tuesday
        case 2:
            day = .wednesday
        case 3:
            day = .thursday
        case 4:
            day = .friday
        case 5:
            day = .saturday
        case 6:
            day = .sunday
        default:
            break
        }
        return day
    }
}
