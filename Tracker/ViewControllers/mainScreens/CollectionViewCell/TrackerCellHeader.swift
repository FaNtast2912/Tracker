//
//  TrackerCellHeader.swift
//  Tracker
//
//  Created by Maksim Zakharov on 12.12.2024.
//
import UIKit

final class TrackerCellHeader: UICollectionReusableView {
    // MARK: - Private Properties
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 19, weight: . bold)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Public Methods
    func configureTitle(_ text: String) {
        titleLabel.text = text
    }
    // MARK: - Private Methods
    private func setUI() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
}
