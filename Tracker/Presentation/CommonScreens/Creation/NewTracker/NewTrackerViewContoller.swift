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
    
    private lazy var newTrackerCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .ypWhite
        collectionView.register(NewTrackerOrEventCell.self, forCellWithReuseIdentifier: NewTrackerOrEventCell.identifier)
        collectionView.register(TrackerCellHeader.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
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
        textField.tintColor = .ypBlue
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
            newTrackersTable.topAnchor.constraint(equalTo: textFieldVStack.bottomAnchor, constant: 24),
            newTrackersTable.leadingAnchor.constraint(equalTo: textFieldVStack.leadingAnchor),
            newTrackersTable.trailingAnchor.constraint(equalTo: textFieldVStack.trailingAnchor),
            newTrackersTable.heightAnchor.constraint(equalToConstant: 150)
        ]
    }
    private var newTrackerCollectionViewConstraint: [NSLayoutConstraint] {
        [
            newTrackerCollection.topAnchor.constraint(equalTo: newTrackersTable.bottomAnchor, constant: 32),
            newTrackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newTrackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newTrackerCollection.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16)
            
        ]
    }
    private var allUiElementsArray: [UIView] {
        [cancelButton,makeTrackerButton,textFieldVStack,newTrackersTable,newTrackerCollection]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        cancelButtonConstraint + makeTrackerButtonConstraint + textFieldVStackConstraint + newTrackersTableConstraint + newTrackerCollectionViewConstraint
    }
    private let trackersTableSections = ["Категория", "Расписание"]
    private let emojiArr: [String] = ["🙂","😻","🌺","🐶","❤️","😱"
                                      ,"😇","😡","🥶","🤔","🍺","🍔",
                                      "🥦","🏓","🥇","🎸","🏝","😪"]
    private let colorArr: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5,.colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18]
    private var selectedCategory : TrackerCategory?
    private var selectedWeekDays: [Int] = []
    private var selectedNewTrackerTitle: String?
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    
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
        guard let selectedNewTrackerTitle, let selectedCategory, let selectedColorIndex, let selectedEmojiIndex else { return }
        let tracker = Tracker(
            name: selectedNewTrackerTitle,
            id: UUID(),
            color: colorArr[selectedColorIndex],
            emoji: emojiArr[selectedEmojiIndex],
            schedule: selectedWeekDays,
            isEvent: false,
            isPinned: false
        )
        trackerStorage.createNewTracker(tracker: tracker, category: selectedCategory.name)
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
    func didReceiveWeekDays(weekDays: [Int]) {
        selectedWeekDays = weekDays
        newTrackersTable.reloadData()
        canCreate()
    }
    
    // MARK: - Private Methods
    
    private func getStringFromWeekDays(weekDays: [Int])  -> String {
        let count = weekDays.count
        let isAllSelected = count == 7
        var resultArr: [String] = []
        for day in weekDays {
            switch day {
            case 1:
                resultArr.append("Пн")
            case 2:
                resultArr.append("Вт")
            case 3:
                resultArr.append("Ср")
            case 4:
                resultArr.append("Чт")
            case 5:
                resultArr.append("Пт")
            case 6:
                resultArr.append("Cб")
            case 7:
                resultArr.append("Вск")
            default:
                print("unexpected day of week")
            }
        }
        return isAllSelected ? "Каждый день" : resultArr.joined(separator: ",")
    }
    private func canCreate() {
        if selectedCategory != nil, selectedNewTrackerTitle != nil, !selectedWeekDays.isEmpty, let selectedColorIndex, let selectedEmojiIndex {
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

extension NewTrackerViewContoller: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = emojiArr.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCellHeader else { return UICollectionReusableView() }
        let sectionNumber = indexPath.section
        switch sectionNumber {
        case 0:
            view.configureTitle("Emoji")
        case 1:
            view.configureTitle("Цвет")
        default:
            assertionFailure("section error")
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTrackerOrEventCell.identifier, for: indexPath) as? NewTrackerOrEventCell else {
            return UICollectionViewCell()
        }
        let sectionNumber = indexPath.section
        switch sectionNumber {
        case 0:
            cell.configureEmojiCell(emoji: emojiArr[indexPath.row])
        case 1:
            cell.configureColorCell(color: colorArr[indexPath.row])
        default:
            assertionFailure("section error")
        }
        return cell
    }
    
}

extension NewTrackerViewContoller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52 , height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let headerSize = CGSize(width: view.frame.width, height: 30)
        return headerSize
    }
}

extension NewTrackerViewContoller: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerOrEventCell else { return }
        let sectionNumber = indexPath.section
        switch sectionNumber {
        case 0:
            if let selectedEmojiIndex {
                guard let cell = collectionView.cellForItem(at: IndexPath(row: selectedEmojiIndex, section: sectionNumber)) as? NewTrackerOrEventCell else { return }
                cell.deselectEmojiCell()
            }
            cell.selectEmojiCell()
            selectedEmojiIndex = indexPath.row
        case 1:
            if let selectedColorIndex {
                guard let cell = collectionView.cellForItem(at: IndexPath(row: selectedColorIndex, section: sectionNumber)) as? NewTrackerOrEventCell else { return }
                cell.deselectColorCell()
            }
            cell.selectColorCell()
            selectedColorIndex = indexPath.row
        default:
            assertionFailure("Invalid section number")
        }
        canCreate()
    }
}
