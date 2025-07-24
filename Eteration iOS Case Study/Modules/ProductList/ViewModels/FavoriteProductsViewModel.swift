//
//  FavoriteProductsViewModel.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//
import Foundation

final class FavoriteProductsViewModel {

    private let coreDataManager: CoreDataManager
    private(set) var favoritedProducts: [Product] = []

    // View callbacks
    var onFavoritesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }

    func loadFavoritedProducts() {
        self.favoritedProducts = coreDataManager.getFavoritedProducts()
        onFavoritesUpdated?()
    }

    func numberOfItems() -> Int {
        favoritedProducts.count
    }

    func favoritedProduct(at index: Int) -> Product? {
        guard favoritedProducts.indices.contains(index) else { return nil }
        return favoritedProducts[index]
    }

    func isProductFavorited(_ id: String) -> Bool {
        coreDataManager.isProductFavorited(id)
    }

    func toggleFavorite(for id: String) {
        if isProductFavorited(id) {
            coreDataManager.removeFromFavorites(id)
        } else {
            coreDataManager.addToFavorites(id)
        }

        // Recompute list
        loadFavoritedProducts()
    }
}

