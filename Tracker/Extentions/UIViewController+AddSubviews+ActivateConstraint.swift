//
//  UIViewController+ActivateConstraint.swift
//  Tracker
//
//  Created by Maksim Zakharov on 26.11.2024.
//
import UIKit

extension UIViewController {
    
    func setUI(to array: [UIView], set constraints: [NSLayoutConstraint]) {
        addSubviews(from: array)
        activateConstraint(set: constraints)
    }
    
    func addSubviews(from array: [UIView]) {
        array.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func activateConstraint(set constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(constraints)
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
