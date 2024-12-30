//
//  ChooseTrackerTypeViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 07.12.2024.
//
import UIKit
final class ChooseTrackerTypeViewController: UIViewController {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    
    // MARK: UI
    var delegateToViewControllers: TrackersDelegateProtocol?
    private lazy var habitButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(habitButtonTapped)
        )
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont(name: "SF Pro", size: 16)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        return button
    }()
    private lazy var eventButton : UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(eventButtonTapped)
        )
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont(name: "SF Pro", size: 16)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        return button
    }()
    private var habitButtonConstraint: [NSLayoutConstraint] {
        [
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.bottomAnchor.constraint(equalTo: eventButton.topAnchor, constant: -16),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
    }
    private var eventButtonConstraint: [NSLayoutConstraint] {
        [
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -281),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [habitButton,eventButton]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        habitButtonConstraint + eventButtonConstraint
    }
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)

    }
    
    // MARK: - IB Actions
    
    @objc
    private func habitButtonTapped() {
        let viewControllerToPresent = NewTrackerViewContoller()
        viewControllerToPresent.title = "Новая привычка"
        guard let delegateToViewControllers else { return }
        viewControllerToPresent.setDelegate(delegate: delegateToViewControllers)
        let newTrackerViewControllerNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
        self.present(newTrackerViewControllerNavigationController, animated: true)
    }
    @objc
    private func eventButtonTapped() {
        let viewControllerToPresent = NewEventViewController()
        viewControllerToPresent.title = "Новое нерегулярное событие"
        guard let delegateToViewControllers else { return }
        viewControllerToPresent.setDelegate(delegate: delegateToViewControllers)
        let newEventViewControllerNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
        self.present(newEventViewControllerNavigationController, animated: true)
    }
    // MARK: - Public Methods

    // MARK: - Private Methods
}
