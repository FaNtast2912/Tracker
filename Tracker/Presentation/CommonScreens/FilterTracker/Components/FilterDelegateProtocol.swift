//
//  FilterProtocol.swift
//  Tracker
//
//  Created by Maksim Zakharov on 28.01.2025.
//

enum FilterState {
    case all
    case today
    case complete
    case uncomplete
}

protocol FilterDelegateProtocol {
    func filter(_ filterState: FilterState)
}
