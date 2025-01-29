//
//  StatisticView.swift
//  Tracker
//
//  Created by Maksim Zakharov on 29.01.2025.
//

import UIKit

final class StatisticView: UIView {
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    // MARK: - Init
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setupView()
        configure(title: title, subtitle: subtitle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subLabel.text = subtitle
    }
    
    func configure(value: String) {
        titleLabel.text = value
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        layer.cornerRadius = 15
        clipsToBounds = true
        addSubview(containerView)
        containerView.addSubviews(titleLabel, subLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            subLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            subLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradientBorder(colors: [.red, .green, .blue])
    }
}


