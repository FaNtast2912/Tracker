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
    
    // UI
    private lazy var trackersStubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 80, height: 80)
        imageView.image = UIImage(named: "statisticsIsEmpty")
        return imageView
    }()
    private lazy var trackersStubLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro", size: 12)
        label.textColor = .ypBlack
        label.text = "Анализировать пока нечего"
        label.textAlignment = .center
        return label
    }()
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
         trackersStubLabel]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        trackersStubImageConstraint + trackersStubLabelConstraint
    }
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        setupNavBar()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        // left button
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
    }
}
