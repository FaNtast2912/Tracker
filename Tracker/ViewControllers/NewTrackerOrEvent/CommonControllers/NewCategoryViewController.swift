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
    private let trackerService = TrackersService.shared
    // MARK: UI
    
    private lazy var categoriesTable: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypWhite
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
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
    private var categoriesStubImageConstraint: [NSLayoutConstraint] {
        [
            newCategoryStubImage.widthAnchor.constraint(equalToConstant: 80),
            newCategoryStubImage.heightAnchor.constraint(equalToConstant: 80),
            newCategoryStubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCategoryStubImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -386)
        ]
    }
    private var categoriesTableConstraint: [NSLayoutConstraint] {
        [
            categoriesTable.bottomAnchor.constraint(equalTo: addNewCategoryButton.topAnchor, constant: -47),
            categoriesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
            //            categoriesTable.heightAnchor.constraint(equalToConstant: 75)
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
        addNewCategoryButtonConstraint + categoryTableEmptyLabelConstraint + categoriesStubImageConstraint + categoriesTableConstraint
    }
    private var categories: [TrackerCategory] = []
    private var selectedCategories: TrackerCategory?
    private let viewModel: CategoryViewModel
    
    // MARK: - Initialization
    
    init(viewModel: CategoryViewModel = CategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        setupBindings()
    }
    
    // MARK: - IB Actions
    
    @objc private func addNewCategoryButtonTapped() {
         let createCategoryVC = CreateCategoryViewController(viewModel: viewModel)
         createCategoryVC.title = "Новая категория"
         let navigationController = UINavigationController(rootViewController: createCategoryVC)
         present(navigationController, animated: true)
     }
    // MARK: - Public Methods
    
    // MARK: - Private Methods

    private func deleteCategory(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Удалить категорию",
            message: "Вы уверены, что хотите удалить категорию «\(viewModel.category(at: indexPath).name)»?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func setupBindings() {
        viewModel.categoriesBinding = { [weak self] _ in
            self?.categoriesTable.reloadData()
        }
        
        viewModel.isEmptyBinding = { [weak self] isEmpty in
            self?.newCategoryStubImage.isHidden = !isEmpty
            self?.categoryTableIsEmptyLabel.isHidden = !isEmpty
        }
    }
    
}

extension NewCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath)
        cell.configure(with: category)
        return cell
    }
}

extension NewCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.category(at: indexPath)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        delegate?.categoryDidSelect(category: selectedCategory)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: "Редактировать") { _ in
                // TO DO: Implement edit functionality
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteCategory(at: indexPath)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}
