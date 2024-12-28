//
//  WeekDayCell.swift
//  Tracker
//
//  Created by Maksim Zakharov on 09.12.2024.
//

import UIKit

final class WeekDayCell: UITableViewCell {
    // MARK: - IB Outlets

    // MARK: - Public Properties

    // MARK: - Private Properties
    private lazy var title: UILabel = {
        let title = UILabel()
        return title
    }()
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.addTarget(self, action: #selector(onOffAction), for: .valueChanged)
        return switcher
        
    }()
    private weak var delegate: WeekDayCellDelegateProtocol?
    private let weekDaysString = [
        "Понедельник",
        "Вторник",
        "Среда",
        "Четверг",
        "Пятница",
        "Суббота",
        "Воскресенье"
    ]
    private var dayOfWeek: Int?
    private var wasChosen: Bool = false
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Overrides Methods

    // MARK: - IB Actions
    @objc private func onOffAction(_ sender: UISwitch) {
        guard let dayOfWeek else { return }
            delegate?.didReceiveWeekDay(weekDay: dayOfWeek)
    }
    // MARK: - Public Methods
    func configureCell(indexPath: IndexPath, delegate: WeekDayCellDelegateProtocol) {
        dayOfWeek = indexPath.row + 1
        guard let dayOfWeek else { return }
        self.delegate = delegate
        backgroundColor = .ypBackground
        title.text = weekDaysString[dayOfWeek - 1]
    }
    // MARK: - Private Methods
    private func setUI() {
        contentView.addSubview(title)
        contentView.addSubview(switcher)
        title.translatesAutoresizingMaskIntoConstraints = false
        switcher.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
}
