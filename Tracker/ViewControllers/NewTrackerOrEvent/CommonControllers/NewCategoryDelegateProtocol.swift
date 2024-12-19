//
//  NewCategoryDelegate.swift
//  Tracker
//
//  Created by Maksim Zakharov on 09.12.2024.
//

protocol NewCategoryDelegateProtocol: AnyObject {
    func categoryDidSelect(category: TrackerCategory)
}
