//
//  AppMetricaModel.swift
//  Tracker
//
//  Created by Maksim Zakharov on 29.01.2025.
//

import Foundation

enum AppMetricaModel {
    enum Event: String {
        case open
        case click
        case close
    }
    
    enum Screen: String {
        case main
    }
    
    enum Item: String {
        case addTrack
        case track
        case filter
        case edit
        case delete
    }
}
