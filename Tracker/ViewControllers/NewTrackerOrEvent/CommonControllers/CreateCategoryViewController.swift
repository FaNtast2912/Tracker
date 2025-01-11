//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 11.01.2025.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont(name: "SF Pro", size: 17)
        textField.tintColor = .ypGray
        textField.backgroundColor = .ypWhite
        textField.layer.cornerRadius = 16
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    private lazy var textFieldVStack: UIStackView = {
        let vStack = UIStackView(arrangedSubviews: [textField,errorLabel])
        vStack.axis = .vertical
        vStack.spacing = 8
        return vStack
    }()
    private lazy var makeCategoryButton : UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(makeCategoryButtonTapped)
        )
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    private var makeTrackerButtonConstraint: [NSLayoutConstraint] {
        [
            makeCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            makeCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            makeCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            makeCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    private var textFieldVStackConstraint: [NSLayoutConstraint] {
        [
            textFieldVStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldVStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldVStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ]
        
    }
    private var allUiElementsArray: [UIView] {
        [makeCategoryButton,textFieldVStack]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        makeTrackerButtonConstraint + textFieldVStackConstraint
    }
    private var selectedNewCategoryTitle: String?
    private let trackerService = TrackersService.shared
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
    // MARK: - IB Actions
    @objc
    private func makeCategoryButtonTapped() {
        guard let categoryName = selectedNewCategoryTitle else { return }
        
        if trackerService.isCategoryExist(categoryName) {
            errorLabel.text = "Категория уже существует!"
            errorLabel.isHidden = false
            return
        } else {
            errorLabel.isHidden = true
        }
        
        let newCategory = TrackerCategory(name: categoryName, trackers: [])
        trackerService.createNewCategory(newCategory: newCategory)
        self.dismiss(animated: true)
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func canCreate() {
        if selectedNewCategoryTitle != nil {
            makeCategoryButton.isEnabled = true
            makeCategoryButton.backgroundColor = .ypBlack
        } else {
            makeCategoryButton.isEnabled = false
            makeCategoryButton.backgroundColor = .ypGray
        }
    }
}

extension CreateCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let totalDigits = text.count + string.count - range.length
        
        if totalDigits > 38 {
            errorLabel.text = "Ограничение 38 символов"
            errorLabel.isHidden = false
            return false
        } else {
            errorLabel.isHidden = true
        }
        return true
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        selectedNewCategoryTitle = textField.text ?? ""
        if selectedNewCategoryTitle != "" {
            canCreate()
        } else {
            selectedNewCategoryTitle = nil
            canCreate()
        }
        if let text = textField.text {
            if text.count > 38 {
                return false
            }
            selectedNewCategoryTitle = text
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
}
