//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 23.11.2024.
//
import Foundation
import UIKit

class TrackersViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, TrackerCellDelegate, TrackersDelegateProtocol {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    // MARK: UI
    private lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
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
        label.font = UIFont(name: "SF Pro", size: 12)
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
        datePicker.locale = Locale(identifier: "ru_RU")
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
    private let trackerStorage = TrackersService.shared
    private var completedTrackers: [TrackerRecord] = []
    private var params = GeometricParams(cellCount: 3,
                                         leftInset: 10,
                                         rightInset: 10,
                                         cellSpacing: 10)
    private var calendar = Calendar.gregorian
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
    }
    // MARK: - IB Actions
    @objc
    func changeDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        showTrackersInDate(selectedDate)
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
        showTrackersInDate(Date())
    }
    func didReceiveCompleteTrackerId(on index: IndexPath, for id: UUID) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        trackersCollectionView.reloadItems(at: [index])
    }
    
    func didReceiveUncompleteTrackerId(on index: IndexPath, for id: UUID) {
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = calendar.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
        trackersCollectionView.reloadItems(at: [index])
    }
    
    // MARK: - Private Methods
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
    }
    
    private func showTrackersInDate(_ date: Date) {
        trackerStorage.clearVisibleTrackers()
        let weekday = calendar.component(.weekday, from: date)
        trackerStorage.appendTrackerInVisibleTrackers(weekday: weekday)
        trackersCollectionView.reloadData()
    }
    
    private func refreshCollection() {
        let isStorageEmpty = trackerStorage.isStorageEmpty
        let isVisibleTrackersEmpty = trackerStorage.isVisibleTrackersEmpty
        
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
        if trackerStorage.isVisibleTrackersEmpty {
            changeTrackersStub(isEmpty: true)
        }
    }
    
    private func changeTrackersStub(isEmpty: Bool) {
        if isEmpty {
            trackersStubImage.image = UIImage(named: "trackersIsEmpty")
            trackersStubLabel.text = "Ничего не найдено"
        } else {
            trackersStubImage.image = UIImage(named: "trackerStubImage")
            trackersStubLabel.text = "Что будем отслеживать?"
        }
        
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
        trackerStorage.visibleCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStorage.countOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCellHeader else { return UICollectionReusableView() }
        let section = indexPath.section
        let title = trackerStorage.titleForSection(section: section)
        view.configureTitle(title)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        let section = indexPath.section
        let item = indexPath.item
        let tracker = trackerStorage.getTrackerDetails(section: section, item: item)
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
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
