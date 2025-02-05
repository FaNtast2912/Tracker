//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Maksim Zakharov on 12.01.2025.
//

import Foundation
typealias Binding<T> = (T) -> Void

final class CategoryViewModel {
    // MARK: - Public properties
    
    var categoriesBinding: Binding<[TrackerCategory]>?
    var isEmptyBinding: Binding<Bool>?
    
    // MARK: - Private properties
    
    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }

    // MARK: - Initializer
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.trackersCategories.filter { $0.name != "Закрепленные" }
        isEmptyBinding?(categories.isEmpty)
    }
    
    func numberOfRows() -> Int {
        return categories.count
    }
    
    func category(at index: IndexPath) -> TrackerCategory {
        return categories[index.row]
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row]
        try? categoryStore.deleteCategory(categoryToDelete)
        loadCategories()
    }
    
    func deleteCategory(name title: String) {
        guard let category = categories.first(where: { $0.name == title }) else { return }
        try? categoryStore.deleteCategory(category)
        loadCategories()
    }
    
    func isCategoryExists(_ name: String) -> Bool {
        return categoryStore.isCategoryExists(name)
    }
    
    func addCategory(_ category: TrackerCategory) {
        try? categoryStore.addNewTrackerCategory(category)
        loadCategories()
    }
}
