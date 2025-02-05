//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Maksim Zakharov on 23.11.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        vc.view.backgroundColor = .red
        assertSnapshot(of: vc, as: .image)
    }
    
}
