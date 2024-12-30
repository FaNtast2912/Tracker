//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 08.12.2024.
//
import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: NewCategoryDelegateProtocol?
    // MARK: - Private Properties
    
    // MARK: UI
    
    private lazy var categoriesTable: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypBackground
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    private lazy var newCategoryStubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 80, height: 80)
        imageView.image = UIImage(named: "trackerStubImage")
        return imageView
    }()
    private lazy var categoryTableIsEmptyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro", size: 12)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Привычки и события можно\n" + "объединить по смыслу"
        return label
    }()
    private lazy var addNewCategoryButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(addNewCategoryButtonTapped)
        )
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    private var addNewCategoryButtonConstraint: [NSLayoutConstraint] {
        [
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    private var categoryTableEmptyLabelConstraint: [NSLayoutConstraint] {
        [
            categoryTableIsEmptyLabel.topAnchor.constraint(equalTo: newCategoryStubImage.bottomAnchor, constant: 8),
            categoryTableIsEmptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableIsEmptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableIsEmptyLabel.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    private var trackersStubImageConstraint: [NSLayoutConstraint] {
        [
            newCategoryStubImage.widthAnchor.constraint(equalToConstant: 80),
            newCategoryStubImage.heightAnchor.constraint(equalToConstant: 80),
            newCategoryStubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCategoryStubImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -386)
        ]
    }
    private var categoriesTableConstraint: [NSLayoutConstraint] {
        [
            categoriesTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -599),
            categoriesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTable.heightAnchor.constraint(equalToConstant: 75)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [
            newCategoryStubImage,
            categoryTableIsEmptyLabel,
            addNewCategoryButton,
            categoriesTable
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        addNewCategoryButtonConstraint + categoryTableEmptyLabelConstraint + trackersStubImageConstraint + categoriesTableConstraint
    }
    private var categories: [TrackerCategory] = []
    private var selectedCategories: TrackerCategory?
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mockCategory = TrackerCategory(name: "Важное", trackers: [])
        selectedCategories = mockCategory
        categories.append(mockCategory)
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        if !categories.isEmpty {
            newCategoryStubImage.isHidden = true
            categoryTableIsEmptyLabel.isHidden = true
        }
        
    }
    
    // MARK: - IB Actions
    
    @objc
    func addNewCategoryButtonTapped() {
        // TO DO add new category
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    
}

extension NewCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.text = "Важное"
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
}

extension NewCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCategories else { return }
        delegate?.categoryDidSelect(category: selectedCategories)
        self.dismiss(animated: true)
    }
}
