//
//  NewTrackerOrEventCell.swift
//  Tracker
//
//  Created by Maksim Zakharov on 17.12.2024.
//
import UIKit

final class NewTrackerOrEventCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = "NewTrackerOrEventCell"
    
    // MARK: - Private Properties
    
    // UI
    
    private var colorCellBackground: UIColor?
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .ypWhite
        label.layer.cornerRadius = 8
        label.font = .systemFont(ofSize: 32)
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var colorViewConstraint: [NSLayoutConstraint] {
        [
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ]
    }
    private var emojiLabelConstraint: [NSLayoutConstraint] {
        [
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40)
        ]
    }
    private var allUiElementsArray: [UIView] {
        [
            colorView,
            emojiLabel
        ]
    }
    private var allConstraintsArray: [NSLayoutConstraint] {
        colorViewConstraint + emojiLabelConstraint
    }
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI(to: allUiElementsArray, set: allConstraintsArray)
    }
    
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    func configureColorCell(color: UIColor) {
        self.colorView.backgroundColor = color
        self.emojiLabel.backgroundColor = .clear
        self.colorCellBackground = color
    }
    func configureEmojiCell(emoji: String) {
        self.emojiLabel.text = emoji
    }
    func selectEmojiCell() {
        backgroundColor = .ypLightGray
        emojiLabel.backgroundColor = .ypLightGray
        layer.cornerRadius = 16
    }
    func deselectEmojiCell() {
        backgroundColor = .clear
        emojiLabel.backgroundColor = .ypWhite
    }
    func selectColorCell() {
        layer.borderWidth = 4
        layer.cornerRadius = 12
        layer.borderColor = self.colorCellBackground?.withAlphaComponent(0.4).cgColor
    }
    func deselectColorCell() {
        layer.borderWidth = 0
    }
    
    // MARK: - Private Methods
}
