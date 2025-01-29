//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 25.11.2024.
//
import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [Tracker] = []
    private var completedCount: Int {
        trackerRecordStore.getRecords().count
    }
    // UI
    private lazy var trackersStubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 80, height: 80)
        imageView.image = UIImage(named: "statisticsIsEmpty")
        return imageView
    }()
    private lazy var trackersStubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var doneTrackersStatisticsView = StatisticView(title: "0", subtitle: "Трекеров завершено")
    
    private lazy var statisticsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                doneTrackersStatisticsView
            ]
        )
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    private var statisticsStackViewConstraint: [NSLayoutConstraint] {
        [
            statisticsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 24),
            statisticsStackView.widthAnchor.constraint(equalToConstant: 343),
            statisticsStackView.heightAnchor.constraint(equalToConstant: 90)
            
        ]
    }
    
    private var trackersStubImageConstraint: [NSLayoutConstraint] {
        [trackersStubImage.widthAnchor.constraint(equalToConstant: 80),
         trackersStubImage.heightAnchor.constraint(equalToConstant: 80),
         trackersStubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         trackersStubImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402)
        ]
    }
    private var trackersStubLabelConstraint: [NSLayoutConstraint] {
        [trackersStubLabel.widthAnchor.constraint(equalToConstant: 343),
         trackersStubLabel.heightAnchor.constraint(equalToConstant: 18),
         trackersStubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         trackersStubLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 490)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [trackersStubImage,
         trackersStubLabel,
         statisticsStackView
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        trackersStubImageConstraint + trackersStubLabelConstraint + statisticsStackViewConstraint
    }
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        setupNavBar()
        updateStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    // MARK: - Private Methods
    private func updateStatistics() {
        doneTrackersStatisticsView.configure(title: "\(completedCount)", subtitle: "Трекеров завершено")
        switch completedCount {
        case 0:
            trackersStubImage.isHidden = false
            trackersStubLabel.isHidden = false
            statisticsStackView.isHidden = true
        default:
            trackersStubImage.isHidden = true
            trackersStubLabel.isHidden = true
            statisticsStackView.isHidden = false
        }
    }
    private func setupNavBar() {
        // left button
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
    }
}
