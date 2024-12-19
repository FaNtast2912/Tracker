//
//  TrackerCell.swift
//  Tracker
//
//  Created by Maksim Zakharov on 07.12.2024.
//

import UIKit


final class TrackerCell: UICollectionViewCell {
    // MARK: - Public Properties
    static let identifier = "TrackerCell"
    // UI
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    // MARK: - Private Properties
    // UI
    private weak var delegate: TrackerCellDelegate?
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.alpha = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var colorViewConstraint: [NSLayoutConstraint] {
        [
            colorView.heightAnchor.constraint(equalToConstant: 90),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorView.topAnchor.constraint(equalTo: topAnchor)
        ]
    }
    private var emojiViewConstraint: [NSLayoutConstraint] {
        [
            emojiView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24)
        ]
    }
    private var emojiLabelConstraint: [NSLayoutConstraint] {
        [
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
        ]
    }
    private var titleLabelConstraint: [NSLayoutConstraint] {
        [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12)
        ]
    }
    private var counterLabelConstraint: [NSLayoutConstraint] {
        [
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            counterLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16)
        ]
    }
    private var doneButtonConstraint: [NSLayoutConstraint] {
        [
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [
            colorView,
            emojiView,
            emojiLabel,
            titleLabel,
            counterLabel,
            doneButton
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        colorViewConstraint + emojiViewConstraint + emojiLabelConstraint + titleLabelConstraint + counterLabelConstraint + doneButtonConstraint
    }
    
    private var isCompletedToday: Bool  = false
    private var trackerID: UUID?
    private var indexPath: IndexPath?
    private var daysDone: Int? = 7
    private var tracker: Tracker?
    // MARK: - Initializers
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
    }
    // MARK: - IB Actions
    @objc
    private func doneButtonTapped() {
        guard let id = trackerID else { return }
        guard let index = indexPath else { return }
        if isCompletedToday {
            delegate?.didReceiveUncompleteTrackerId(on: index, for: id)
        } else {
            delegate?.didReceiveCompleteTrackerId(on: index, for: id)
        }
    }
    // MARK: - Public Methods
    func configureCell(tracker: Tracker, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath, delegate: TrackerCellDelegate) {
        self.tracker = tracker
        self.indexPath = indexPath
        self.trackerID = tracker.id
        self.isCompletedToday = isCompletedToday
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        counterLabel.text = "\(completedDays) дней"
        self.delegate = delegate
        colorView.backgroundColor = tracker.color
        doneButton.tintColor = .ypWhite
        doneButton.backgroundColor = tracker.color
        let plusImage = UIImage(systemName: "plus")
        let doneImage = UIImage(named: "doneButton")
        let image = !isCompletedToday ? plusImage : doneImage
        doneButton.alpha = isCompletedToday ?  0.3 : 1
        doneButton.setImage(image, for: .normal)
        
    }
    // MARK: - Private Methods
}
