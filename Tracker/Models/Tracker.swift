//
//  TrackerModel.swift
//  Tracker
//
//  Created by Maksim Zakharov on 27.11.2024.
//
import UIKit

struct Tracker {
    let name: String
    let id: UUID
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}
