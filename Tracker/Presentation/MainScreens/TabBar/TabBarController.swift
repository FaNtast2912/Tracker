//
//  TabBarController.swift
//  Tracker
//
//  Created by Maksim Zakharov on 25.11.2024.
//
import Foundation
import UIKit

final class TabBarController: UITabBarController {
    // private properties
    let trackersTitle = NSLocalizedString("trakersTitle", comment: "trackers title vc and tabs")
    let statisticsTitle = NSLocalizedString("statisticsTitle", comment: "statistics title vc and tabs")
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        trackersViewController.title = trackersTitle
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.navigationBar.prefersLargeTitles = true
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.title = statisticsTitle
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.navigationBar.prefersLargeTitles = true

        trackersViewController.tabBarItem = UITabBarItem(
            title: trackersTitle,
            image: UIImage(named: "trackersIcon"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: statisticsTitle,
            image: UIImage(named: "statisticsIcon"),
            selectedImage: nil
        )
        self.viewControllers = [trackersNavigationController, statisticsNavigationController]
        setUITabBarAppearance()
    }
    
    private func setUITabBarAppearance() {
        let uITabBarAppearance = UITabBarAppearance()
        uITabBarAppearance.configureWithOpaqueBackground()
        uITabBarAppearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        uITabBarAppearance.stackedLayoutAppearance.disabled.iconColor = .ypGray
        tabBar.standardAppearance = uITabBarAppearance
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
    }
}
