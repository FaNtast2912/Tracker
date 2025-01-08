//
//  OnboardViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 08.01.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackerStubImage")
        return imageView
    }()
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    private lazy var onboardingButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(onboardingButtonTapped)
        )
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private var backgroundImageConstraint: [NSLayoutConstraint] {
        [
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor)
        ]
    }
    
    private var onboardingLabelConstraint: [NSLayoutConstraint] {
        [
            onboardingLabel.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -160),
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingLabel.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    
    private var onboardingButtonConstraint: [NSLayoutConstraint] {
        [
            onboardingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [
            onboardingButton,
            backgroundImage,
            onboardingLabel
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        onboardingButtonConstraint + onboardingLabelConstraint + backgroundImageConstraint
    }
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
    // MARK: - IB Actions
    @objc
    func onboardingButtonTapped() {
        let tabBarViewController = TabBarController()
        tabBarViewController.modalPresentationStyle = .fullScreen
        present(tabBarViewController, animated: true)
    }
    // MARK: - Public Methods
    
    // MARK: - Private Methods
}
