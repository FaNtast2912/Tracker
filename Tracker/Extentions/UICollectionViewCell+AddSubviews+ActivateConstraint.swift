//
//  Untitled.swift
//  Tracker
//
//  Created by Maksim Zakharov on 07.12.2024.
//
import UIKit

extension UICollectionViewCell {
    
    func setUI(to array: [UIView], set constraints: [NSLayoutConstraint]) {
        addSubviews(from: array)
        activateConstraint(set: constraints)
    }
    
    func addSubviews(from array: [UIView]) {
        array.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    func activateConstraint(set constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(constraints)
    }
    
}
