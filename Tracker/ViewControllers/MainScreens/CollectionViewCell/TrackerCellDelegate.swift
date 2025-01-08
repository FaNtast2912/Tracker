//
//  TrackerCellDelegate.swift
//  Tracker
//
//  Created by Maksim Zakharov on 13.12.2024.
//
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didReceiveCompleteTrackerId(on index: IndexPath,for id: UUID)
    func didReceiveUncompleteTrackerId(on index: IndexPath,for id: UUID)
}
