//
//  NewTrackerViewContoller.swift
//  Tracker
//
//  Created by Maksim Zakharov on 08.12.2024.
//
import UIKit

final class NewTrackerViewContoller: UIViewController, NewCategoryDelegateProtocol, ScheduleDelegateProtocol {
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var delegate: TrackersDelegateProtocol?
    private let trackerStorage = TrackersService.shared
    // MARK: UI
    private lazy var newTrackersTable: UITableView = {
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
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro", size: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        return label
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont(name: "SF Pro", size: 17)
        textField.tintColor = .ypGray
        textField.backgroundColor = .ypBackground
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
    private lazy var cancelButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(cancelButtonTapped)
        )
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    private lazy var makeTrackerButton : UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(makeTrackerButtonTapped)
        )
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont(name: "SF Pro", size: 16)
        button.backgroundColor = .ypGray
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()
    private var cancelButtonConstraint: [NSLayoutConstraint] {
        [
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.trailingAnchor.constraint(equalTo: makeTrackerButton.leadingAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ]
    }
    private var makeTrackerButtonConstraint: [NSLayoutConstraint] {
        [
            makeTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            makeTrackerButton.widthAnchor.constraint(equalToConstant: 161),
            makeTrackerButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            makeTrackerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
    }
    private var textFieldVStackConstraint: [NSLayoutConstraint] {
        [
            textFieldVStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldVStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldVStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -561),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ]
        
    }
    private var newTrackersTableConstraint: [NSLayoutConstraint] {
        [
            newTrackersTable.topAnchor.constraint(equalTo: textFieldVStack.bottomAnchor, constant: 24),
            newTrackersTable.leadingAnchor.constraint(equalTo: textFieldVStack.leadingAnchor),
            newTrackersTable.trailingAnchor.constraint(equalTo: textFieldVStack.trailingAnchor),
            newTrackersTable.heightAnchor.constraint(equalToConstant: 150)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [cancelButton,makeTrackerButton,textFieldVStack,newTrackersTable]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        cancelButtonConstraint + makeTrackerButtonConstraint + textFieldVStackConstraint + newTrackersTableConstraint
    }
    private let trackersTableSections = ["Категория", "Расписание"]
    private var selectedCategory : TrackerCategory?
    private var selectedWeekDays: [Weekday] = []
    private var selectedNewTrackerTitle: String?
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
    // MARK: - IB Actions
    @objc
    func cancelButtonTapped() {
        view?.window?.rootViewController?.dismiss(animated: true)
    }
    @objc
    func makeTrackerButtonTapped() {
        guard let title = selectedNewTrackerTitle, let category = selectedCategory else { return }
        guard let mockColor = UIColor(named: "ypRed") else { return }
        let tracker = Tracker(name: title, id: UUID(), color: mockColor, emoji: "🐙", schedule: selectedWeekDays)
        trackerStorage.createNewTracker(tracker: tracker)
        delegate?.didReceiveRefreshRequest()
        view?.window?.rootViewController?.dismiss(animated: true)
    }
    // MARK: - Public Methods
    func setDelegate(delegate: TrackersDelegateProtocol) {
        self.delegate = delegate
    }
    func categoryDidSelect(category: TrackerCategory) {
        selectedCategory = category
        newTrackersTable.reloadData()
        canCreate()
    }
    func didReceiveWeekDays(weekDays: [Weekday]) {
        selectedWeekDays = weekDays
        newTrackersTable.reloadData()
        canCreate()
    }
    // MARK: - Private Methods
    private func getStringFromWeekDays(weekDays: [Weekday])  -> String {
        let count = weekDays.count
        let isAllSelected = count == 7
        var resultArr: [String] = []
        for day in weekDays {
            switch day {
            case .monday:
                resultArr.append("Пн")
            case .tuesday:
                resultArr.append("Вт")
            case .wednesday:
                resultArr.append("Ср")
            case .thursday:
                resultArr.append("Чт")
            case .friday:
                resultArr.append("Пт")
            case .saturday:
                resultArr.append("Cб")
            case .sunday:
                resultArr.append("Вск")
            }
        }
        return isAllSelected ? "Каждый день" : resultArr.joined(separator: ",")
    }
    private func canCreate() {
        if selectedCategory != nil, selectedNewTrackerTitle != nil, !selectedWeekDays.isEmpty {
            makeTrackerButton.isEnabled = true
            makeTrackerButton.backgroundColor = .ypBlack
        } else {
            makeTrackerButton.isEnabled = false
            makeTrackerButton.backgroundColor = .ypGray
        }
    }
}

extension NewTrackerViewContoller: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let totalDigits = text.count + string.count - range.length
        
        if totalDigits > 38 {
            errorLabel.isHidden = false
            return false
        } else {
            errorLabel.isHidden = true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        selectedNewTrackerTitle = textField.text ?? ""
        canCreate()
        return true
    }
    
    func NewTrackerViewContoller(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if let text = textField.text {
            if text.count > 38 {
                return false
            }
            textField.resignFirstResponder()
            return true
        }
        return false
        
    }
}

extension NewTrackerViewContoller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackersTableSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCellHeader else { return UICollectionReusableView() }
        let title = trackerStorage.titleForSection(section: indexPath.section)
            view.configureTitle(title)
            return view
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = trackersTableSections[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory?.name
        } else {
            cell.detailTextLabel?.text = getStringFromWeekDays(weekDays: selectedWeekDays)
        }
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
}

extension NewTrackerViewContoller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let select = trackersTableSections[indexPath.row]
        switch select {
        case "Категория":
            let viewControllerToPresent = NewCategoryViewController()
            viewControllerToPresent.title = "Категория"
            viewControllerToPresent.delegate = self
            let newCategoryNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
            self.present(newCategoryNavigationController, animated: true)
        case "Расписание":
            let viewControllerToPresent = ScheduleViewController()
            viewControllerToPresent.title = "Расписание"
            viewControllerToPresent.setDelegate(delegate: self)
            let newCategoryNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
            self.present(newCategoryNavigationController, animated: true)
        default:
            debugPrint("не верный выбор секции")
        }
    }
}
