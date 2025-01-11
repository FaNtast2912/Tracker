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
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    private lazy var onboardingButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
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
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ]
    }
    
    private var onboardingButtonConstraint: [NSLayoutConstraint] {
        [
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [
            backgroundImage,
            onboardingButton,
            onboardingLabel
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        onboardingButtonConstraint + onboardingLabelConstraint + backgroundImageConstraint
    }
    // MARK: - Initializers
    init(image: UIImage, title: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        backgroundImage.image = image
        onboardingLabel.text = title
        onboardingButton.setTitle(buttonTitle, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
