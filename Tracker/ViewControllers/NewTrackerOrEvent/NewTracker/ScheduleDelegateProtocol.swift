//
//  ScheduleDelegate.swift
//  Tracker
//
//  Created by Maksim Zakharov on 10.12.2024.
//

protocol ScheduleDelegateProtocol: AnyObject {
    func didReceiveWeekDays(weekDays: [Weekday])
}
