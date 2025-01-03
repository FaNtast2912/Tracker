//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 23.11.2024.
//
import UIKit

final class TrackersViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, TrackerCellDelegate, TrackersDelegateProtocol {
    
    // MARK: - Private Properties
    
    // MARK: UI
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
    private var trackersStubImageConstraint: [NSLayoutConstraint] {
        [trackersStubImage.widthAnchor.constraint(equalToConstant: 80),
         trackersStubImage.heightAnchor.constraint(equalToConstant: 80),
         trackersStubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         trackersStubImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402)
        ]
    }
    private var trackersStubLabelConstraint: [NSLayoutConstraint] {
        [trackersStubLabel.widthAnchor.constraint(equalToConstant: 343),
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
        [trackersStubImage,
         trackersStubLabel,
         trackersCollectionView
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        trackersStubImageConstraint + trackersStubLabelConstraint + trackerCollectionConstraint
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
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        view.backgroundColor = .ypWhite
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        setupNavBar()
        showTrackersInDate(date)
        refreshCollection()
        trackersService.trackerCategoryStore.delegate = self
    }
    
    // MARK: - IB Actions
    
    @objc
    func changeDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: selectedDate)
        guard let date = Calendar.current.date(from: dateComponents) else { return }
        showTrackersInDate(date)
        refreshCollection()
    }
    @objc
    func didTapAddTrackerButton() {
        let viewControllerToPresent = ChooseTrackerTypeViewController()
        viewControllerToPresent.title = "Создание трекера"
        viewControllerToPresent.delegateToViewControllers = self
        let chooseTrackerTypeNavigationController = UINavigationController(rootViewController: viewControllerToPresent)
        self.present(chooseTrackerTypeNavigationController, animated: true)
    }
    
    // MARK: - Public Methods
    
    func didReceiveRefreshRequest() {
        showTrackersInDate(currentDate)
        refreshCollection()
    }
    
    func didReceiveCompleteTrackerId(on index: IndexPath, for id: UUID) {
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
    
    private func showTrackersInDate(_ date: Date) {
        let completedTrackers = trackersService.getRecords()
        trackersService.clearVisibleTrackers()
        let weekday = convertWeekDay(weekDay: calendar.component(.weekday, from: date))
        trackersService.appendTrackerInVisibleTrackers(weekday: weekday, from: completedTrackers, selectedDate: date)
        trackersCollectionView.reloadData()
    }
    
    private func convertWeekDay(weekDay: Int) -> Int {
        switch weekDay {
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 3
        case 5:
            return 4
        case 6:
            return 5
        case 7:
            return 6
        case 1:
            return 7
        default:
            print("unexpected week day")
        }
        return 0
    }
    
    private func refreshCollection() {
        let isStorageEmpty = trackersService.isStorageEmpty
        let isVisibleTrackersEmpty = trackersService.isVisibleTrackersEmpty
        
        if isStorageEmpty {
            trackersCollectionView.isHidden = true
            changeTrackersStub(isEmpty: false)
        }
        if !isStorageEmpty && isVisibleTrackersEmpty {
            trackersCollectionView.isHidden = true
            changeTrackersStub(isEmpty: true)
        }
        if !isStorageEmpty && !isVisibleTrackersEmpty {
            trackersCollectionView.isHidden = false
            changeTrackersStub(isEmpty: false)
        }
    }
    
    internal func updateSearchResults(for searchController: UISearchController) {
        if trackersService.isVisibleTrackersEmpty {
            changeTrackersStub(isEmpty: true)
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
        let completedTrackers = trackersService.getRecords()
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configureCell(tracker: tracker,
                           isCompletedToday: isCompletedToday,
                           completedDays: completedDays,
                           indexPath: indexPath,
                           delegate: self
        )
        
        if datePicker.date > Date() {
            cell.doneButton.isHidden = true
        }  else {
            cell.doneButton.isHidden = false
        }
        cell.prepareForReuse()
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
        return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
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
