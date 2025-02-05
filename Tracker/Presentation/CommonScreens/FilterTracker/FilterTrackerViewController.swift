//
//  FilterTrackerViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 28.01.2025.
//
import UIKit

final class FilterViewController: UIViewController {
    // MARK: - Public Properties
    private let tableList: [FilterState: String] = [
        .all: "Все трекеры",
        .today: "Трекеры на сегодня",
        .complete: "Завершенные",
        .uncomplete: "Не завершенные"
    ]
    private var filterDelegate: FilterDelegateProtocol?
    private var filterState: FilterState = .all {
        didSet {
            filtersTable.reloadData()
        }
    }
    private lazy var filtersTable: UITableView = {
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
    private var filtersTableConstraint: [NSLayoutConstraint] {
        [
            filtersTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filtersTable.heightAnchor.constraint(equalToConstant: CGFloat(4 * 75))
            
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        filtersTableConstraint
    }
    private var allUiElementsArray: [UIView] {
        [
            filtersTable
        ]
    }
    // MARK: - Private Properties
    
    // MARK: - Initializers
    init(filterDelegate: FilterDelegateProtocol?, filterState: FilterState) {
        super.init(nibName: nil, bundle: nil)
        self.filterDelegate = filterDelegate
        self.filterState = filterState
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.title = "Фильтры"
        setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
}


extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let state: FilterState = indexPath.row == 0 ? .all : (indexPath.row == 1 ? .today : (indexPath.row == 2 ? .complete : .uncomplete))
        self.filterState = state
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.filterDelegate?.filter(state)
            self.dismiss(animated: true)
        }
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let orderedKeys: [FilterState] = [.all, .today, .complete, .uncomplete]
        let currentKey = orderedKeys[indexPath.row]
        
        cell.textLabel?.text = tableList[currentKey]
        cell.accessoryType = currentKey == filterState ? .checkmark : .none
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        return cell
    }
}
