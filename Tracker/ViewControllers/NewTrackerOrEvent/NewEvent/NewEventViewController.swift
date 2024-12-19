//
//  NewEventViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 07.12.2024.
//
import UIKit

final class NewEventViewController: UIViewController, NewCategoryDelegateProtocol {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private weak var delegate: TrackersDelegateProtocol?
    private let trackerStorage = TrackersService.shared
    // MARK: UI
    private lazy var newEventTable: UITableView = {
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
        label.font = UIFont.systemFont(ofSize: 17)
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
            textFieldVStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ]
        
    }
    private var newTrackersTableConstraint: [NSLayoutConstraint] {
        [
            newEventTable.topAnchor.constraint(equalTo: textFieldVStack.bottomAnchor, constant: 24),
            newEventTable.leadingAnchor.constraint(equalTo: textFieldVStack.leadingAnchor),
            newEventTable.trailingAnchor.constraint(equalTo: textFieldVStack.trailingAnchor),
            newEventTable.heightAnchor.constraint(equalToConstant: 75)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [cancelButton,makeTrackerButton,textFieldVStack,newEventTable]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        cancelButtonConstraint + makeTrackerButtonConstraint + textFieldVStackConstraint + newTrackersTableConstraint
    }
    private var selectedCategory : TrackerCategory?
    private var selectedNewTrackerTitle: String?
    private var eventSchedule: [Weekday] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday
    ]
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
    // MARK: - IB Actions
    @objc
    private func cancelButtonTapped() {
        view?.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc
    private func makeTrackerButtonTapped() {
        guard let title = selectedNewTrackerTitle, let category = selectedCategory else { return }
        guard let mockColor = UIColor(named: "ypRed") else { return }
        let tracker = Tracker(
            name: title,
            id: UUID(),
            color: mockColor,
            emoji: "🐙",
            schedule: eventSchedule,
            isEvent: true
        )
        trackerStorage.createNewTracker(tracker: tracker)
        delegate?.didReceiveRefreshRequest()
        view?.window?.rootViewController?.dismiss(animated: true)
    }
    // MARK: - Public Methods
    func categoryDidSelect(category: TrackerCategory) {
        selectedCategory = category
        newEventTable.reloadData()
        canCreate()
    }
    func setDelegate(delegate: TrackersDelegateProtocol) {
        self.delegate = delegate
    }
    // MARK: - Private Methods
    private func canCreate() {
        if selectedCategory != nil, selectedNewTrackerTitle != nil {
            makeTrackerButton.isEnabled = true
            makeTrackerButton.backgroundColor = .ypBlack
        } else {
            makeTrackerButton.isEnabled = false
            makeTrackerButton.backgroundColor = .ypGray
        }
    }
    
}

extension NewEventViewController: UITextFieldDelegate {
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
        if selectedNewTrackerTitle != "" {
            canCreate()
        }
        if let text = textField.text {
            if text.count > 38 {
                return false
            }
            selectedNewTrackerTitle = text
            textField.resignFirstResponder()
            return true
        }
        return false
        
    }
}

extension NewEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCellHeader else { return UICollectionReusableView() }
        let title = trackerStorage.titleForSection(section: indexPath.section)
        view.configureTitle(title)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Категории"
        cell.detailTextLabel?.text = selectedCategory?.name
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
}

extension NewEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewControllerToPresent = NewCategoryViewController()
        viewControllerToPresent.delegate = self
        viewControllerToPresent.title = "Категория"
        let newCategoryNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
        self.present(newCategoryNavigationController, animated: true)
    }
}
