//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 23.11.2024.
//
import UIKit

final class TrackersViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, TrackerCellDelegate, TrackersDelegateProtocol, FilterDelegateProtocol {
    
    // MARK: - Private Properties
    
    // MARK: UI
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSLocalizedString("filterButtonTitle", comment: "title for filter button")
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 16
        button.tintColor = .ypAllStateWhite
        button.backgroundColor = .ypBlue
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerCellHeader.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    private lazy var trackersStubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 80, height: 80)
        imageView.image = UIImage(named: "trackerStubImage")
        imageView.isHidden = false
        return imageView
    }()
    private lazy var trackersStubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.isHidden = false
        return label
    }()
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.addTarget(self, action: #selector(changeDate(_:)) , for: .valueChanged)
        return datePicker
    }()
    private var filterButtonConstraint: [NSLayoutConstraint] {
        [
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 131),
            filterButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16)
        ]
    }
    private var trackersStubImageConstraint: [NSLayoutConstraint] {
        [
            trackersStubImage.widthAnchor.constraint(equalToConstant: 80),
            trackersStubImage.heightAnchor.constraint(equalToConstant: 80),
            trackersStubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackersStubImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402)
        ]
    }
    private var trackersStubLabelConstraint: [NSLayoutConstraint] {
        [
            trackersStubLabel.widthAnchor.constraint(equalToConstant: 343),
            trackersStubLabel.heightAnchor.constraint(equalToConstant: 18),
            trackersStubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackersStubLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 490)
        ]
    }
    private var trackerCollectionConstraint: [NSLayoutConstraint] {
        [
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
    }
    private var searchController: UISearchController {
        let searchController = UISearchController()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        searchController.searchBar.searchTextField.tintColor = .ypBlack
        return searchController
    }
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private var allUiElementsArray: [UIView] {
        [
        trackersStubImage,
        trackersStubLabel,
        trackersCollectionView,
        filterButton
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        trackersStubImageConstraint + trackersStubLabelConstraint + trackerCollectionConstraint + filterButtonConstraint
    }
    // MARK: setup Tracker, category
    private let trackersService = TrackersService.shared
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    private var currentDate: Date {
        let currentDate = Date()
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: currentDate)
        guard let date = calendar.date(from: dateComponents) else { return Date() }
        return date
    }
    private var filterState: FilterState = .all
    private var selectedDate: Date?
    private let analyticsService = AnalyticsService()
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedDate = datePicker.date
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        setupNavBar()
        showTrackersInDate(datePicker.date)
        refreshCollection()
        trackersService.trackerCategoryStore.delegate = self
        trackersCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: .open, screen: .main, item: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, screen: .main, item: nil)
    }
    
    // MARK: - IB Actions
    
    @objc
    func changeDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        self.selectedDate = selectedDate
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: selectedDate)
        guard let date = Calendar.current.date(from: dateComponents) else { return }
        showTrackersInDate(date)
        refreshCollection()
    }
    @objc
    func didTapAddTrackerButton() {
        analyticsService.report(event: .click, screen: .main, item: .addTrack)
        let viewControllerToPresent = ChooseTrackerTypeViewController()
        viewControllerToPresent.title = "Создание трекера"
        viewControllerToPresent.delegateToViewControllers = self
        let chooseTrackerTypeNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
        self.present(chooseTrackerTypeNavigationController, animated: true)
    }
    
    @objc
    func filterButtonTapped(_ sender: UIButton) {
        analyticsService.report(event: .click, screen: .main, item: .filter)
        let filterViewController = FilterViewController(filterDelegate: self, filterState: filterState)
        let filterNavController = UINavigationController(rootViewController: filterViewController)
        self.present(filterNavController, animated: true)
    }
    
    // MARK: - Public Methods
    func filter(_ filterState: FilterState) {
        self.filterState = filterState
        switch filterState {
        case .today:
            datePicker.date = currentDate
        default:
            break
        }
        trackersService.getVisibleCategories(for: datePicker.date, and: filterState)
        refreshCollection()
        trackersCollectionView.reloadData()
    }
    
    func didReceiveRefreshRequest() {
        showTrackersInDate(currentDate)
        refreshCollection()
    }
    
    func didReceiveCompleteTrackerId(on index: IndexPath, for id: UUID) {
        analyticsService.report(event: .click, screen: .main, item: .track)
        let selectedDay = datePicker.date
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: selectedDay)
        guard let date = Calendar.current.date(from: dateComponents) else { return }
        trackersService.addTrackerRecord(id, date: date)
        trackersCollectionView.reloadItems(at: [index])
    }
    
    func didReceiveUncompleteTrackerId(on index: IndexPath, for id: UUID) {
        let selectedDay = datePicker.date
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: selectedDay)
        guard let date = Calendar.current.date(from: dateComponents) else { return }
        trackersService.removeTrackerRecord(id, date: date)
        trackersCollectionView.reloadItems(at: [index])
    }
    
    // MARK: - Private Methods
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        let selectedDay = datePicker.date
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: selectedDay)
        guard let date = Calendar.current.date(from: dateComponents) else { return false }
        return trackersService.isTrackerRecordExist(id, date: date)
    }
    
    func showTrackersInDate(_ date: Date) {
        trackersService.getVisibleCategories(for: date, and: filterState)
        trackersCollectionView.reloadData()
    }
    
    private func refreshCollection() {
        let isStorageEmpty = trackersService.isStorageEmpty
        let isVisibleTrackersEmpty = trackersService.isVisibleTrackersEmpty
        
        if isStorageEmpty {
            trackersCollectionView.isHidden = true
            filterButton.isHidden = true
            changeTrackersStub(isEmpty: false)
        }
        if !isStorageEmpty && isVisibleTrackersEmpty {
            trackersCollectionView.isHidden = true
            filterButton.isHidden = false
            changeTrackersStub(isEmpty: true)
        }
        if !isStorageEmpty && !isVisibleTrackersEmpty {
            trackersCollectionView.isHidden = false
            filterButton.isHidden = false
            changeTrackersStub(isEmpty: false)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        if !query.isEmpty {
            trackersService.filterTrackersByName(query, date: datePicker.date)
            refreshCollection()
            trackersCollectionView.reloadData()
        }
    }
    
    private func changeTrackersStub(isEmpty: Bool) {
        trackersStubImage.image = isEmpty ? UIImage(named: "trackersIsEmpty") : UIImage(named: "trackerStubImage")
        trackersStubLabel.text = isEmpty ? "Ничего не найдено" : "Что будем отслеживать?"
    }
    
    private func setupNavBar() {
        // left button
        let navBarLeftButtonImage = UIImage(named: "addTrackerIcon")?.withTintColor(.ypBlack)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: navBarLeftButtonImage,
            style: .done,
            target: self,
            action: #selector(didTapAddTrackerButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        // right button
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        // search controller
        navigationItem.searchController = searchController
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackersService.visibleCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackersService.countOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCellHeader else { return UICollectionReusableView() }
        let section = indexPath.section
        let title = trackersService.titleForSection(section: section)
        view.configureTitle(title)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let section = indexPath.section
        let item = indexPath.item
        let tracker = trackersService.getTrackerDetails(section: section, item: item)
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = trackersService.getRecords().filter { $0.id == tracker.id }.count
        
        cell.configureCell(
            tracker: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath,
            delegate: self
        )
        
        cell.doneButton.isHidden = datePicker.date > Date()
        
        return cell
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemCount : CGFloat = 2
        let space: CGFloat = 9
        let width : CGFloat = (collectionView.bounds.width - space - 32) / itemCount
        let height : CGFloat = 148
        return CGSize(width: width , height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let lastSection = trackersService.visibleCount - 1
        switch section {
        case lastSection:
            return UIEdgeInsets(top: 10, left: 16, bottom: 80, right: 16)
        default:
            return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let headerSize = CGSize(width: view.frame.width, height: 30)
        return headerSize
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        trackersCollectionView.performBatchUpdates {
            trackersCollectionView.deleteItems(at: update.deletedIndexes.map { IndexPath(item: $0, section: 0) })
            trackersCollectionView.insertItems(at: update.insertedIndexes.map { IndexPath(item: $0, section: 0) })
            trackersCollectionView.reloadItems(at: update.updatedIndexes.map { IndexPath(item: $0, section: 0) })
            update.movedIndexes.forEach { move in
                trackersCollectionView.moveItem(
                    at: IndexPath(item: move.oldIndex, section: 0),
                    to: IndexPath(item: move.newIndex, section: 0)
                )
            }
        }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            let selectedTracker = trackersService.getTrackerDetails(section: indexPath.section, item: indexPath.item)
            let selectedCategory = trackersService.trackerCategoryStore.trackersCategories.first { category in
                category.trackers.contains { $0.id == selectedTracker.id }
            }
            let editAction = UIAction(
                title: "Редактировать"
            ) { [weak self] _ in
                guard let self else { return }
                analyticsService.report(event: .click, screen: .main, item: .edit)
                let completedTrackers = trackersService.getRecords()
                let completedDays = completedTrackers.filter { $0.id == selectedTracker.id }.count
                let localizedString = String.localizedStringWithFormat(NSLocalizedString("numberOfDay", comment: "number of day"), completedDays)
                let viewControllerToPresent = EditTrackerViewContoller(selected: selectedTracker, selectedCategory: selectedCategory, completedDays: localizedString)
                viewControllerToPresent.title = !selectedTracker.isEvent ? "Редактирование привычки" : "Редактирование нерегулярного события"
                viewControllerToPresent.setDelegate(delegate: self)
                let newTrackerViewControllerNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
                self.present(newTrackerViewControllerNavigationController, animated: true)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                guard let self = self, let date = selectedDate else { return }
                analyticsService.report(event: .click, screen: .main, item: .delete)
                try? trackersService.deleteTracker(selectedTracker)
                let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
                guard let date = Calendar.current.date(from: dateComponents) else { return }
                showTrackersInDate(date)
                refreshCollection()
            }
            
            let pinAction = UIAction(
                title: selectedTracker.isPinned ? "Открепить" : "Закрепить"
            ) { [weak self] _ in
                guard let self else { return }
                
                if selectedTracker.isPinned {
                    trackersService.unpinTracker(selectedTracker)
                    didReceiveRefreshRequest()
                } else {
                    trackersService.pinTracker(selectedTracker)
                    didReceiveRefreshRequest()
                }
                
                showTrackersInDate(currentDate)
                refreshCollection()
            }
            
            return UIMenu(children: [pinAction, editAction, deleteAction])
        }
    }
}
