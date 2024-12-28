//
//  Untitled.swift
//  Tracker
//
//  Created by Maksim Zakharov on 09.12.2024.
//
import UIKit
final class ScheduleViewController:  UIViewController, WeekDayCellDelegateProtocol {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    // MARK: UI
    private var delegate: ScheduleDelegateProtocol?
    private var schedule: Set<Int> = []
    private lazy var scheduleTable: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypBackground
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.register(WeekDayCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    private lazy var scheduleDoneButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(scheduleDoneButtonTapped)
        )
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private var scheduleDoneButtonConstraint: [NSLayoutConstraint] {
        [
            scheduleDoneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            scheduleDoneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleDoneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scheduleDoneButton.heightAnchor.constraint(equalToConstant: 60)
        ]
    }
    private var scheduleTableConstraint: [NSLayoutConstraint] {
        [
            scheduleTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -149),
            scheduleTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTable.heightAnchor.constraint(equalToConstant: 525)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [
            scheduleDoneButton,
            scheduleTable
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        scheduleDoneButtonConstraint + scheduleTableConstraint
    }
//    private var selectedDays: Schedule?
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
    // MARK: - IB Actions
    @objc
    func scheduleDoneButtonTapped() {
        let arr = Array(schedule)
        delegate?.didReceiveWeekDays(weekDays: arr.sorted())
        self.dismiss(animated: true)
    }
    // MARK: - Public Methods
    func setDelegate(delegate: ScheduleDelegateProtocol) {
        self.delegate = delegate
    }
    
    func didReceiveWeekDay(weekDay: Int) {
        if schedule.contains(weekDay) {
            schedule.remove(weekDay)
        } else {
            schedule.insert(weekDay)
        }
    }
    // MARK: - Private Methods
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WeekDayCell else {
                    return UITableViewCell()
                }
        cell.configureCell(indexPath: indexPath, delegate: self)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
    }
}
