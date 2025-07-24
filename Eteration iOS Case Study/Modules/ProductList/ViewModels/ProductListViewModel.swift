//
//  ProductListViewModel.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation

final class ProductListViewModel {

    private(set) var products: [Product] = []
    private(set) var filteredProducts: [Product] = []
    
    private(set) var lastAppliedFilter: ProductFilter?
    private var searchText: String = ""
    
    private let service: ProductServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol

    // Callbacks to notify the view controller
    var onProductsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    var favoritedProducts: [Product] {
        coreDataManager.getFavoritedProducts(from: products)
    }
    
    var numberOfFavoritedProducts: Int {
        favoritedProducts.count
    }

    init(service: ProductServiceProtocol = ProductService(),
        coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.service = service
        self.coreDataManager = coreDataManager
    }

    @MainActor
    func loadProducts() async {
        onLoadingChanged?(true)
        do {
            let products = try await service.fetchProducts()

            self.products = products
            self.filteredProducts = products
            
            // Save products to coreData
            coreDataManager.saveFetchedProducts(products)
            
            // Notify View Controller
            onProductsUpdated?()
        } catch {
            onError?(error.localizedDescription)
        }
        onLoadingChanged?(false)
    }

    func product(at index: Int) -> Product? {
        guard filteredProducts.indices.contains(index) else { return nil }
        return filteredProducts[index]
    }
    
    var numberOfProducts: Int {
        filteredProducts.count
    }
    
    func favoritedProduct(at index: Int) -> Product? {
        guard favoritedProducts.indices.contains(index) else { return nil }
        return favoritedProducts[index]
    }
}

// MARK: - Favorite Product

extension ProductListViewModel {
    func isProductFavorited(_ id: String) -> Bool {
        coreDataManager.isProductFavorited(id)
    }

    func toggleFavorite(for id: String) {
        if isProductFavorited(id) {
            coreDataManager.removeFromFavorites(id)
        } else {
            coreDataManager.addToFavorites(id)
        }
    }
}

// MARK: - Add Product to Cart

extension ProductListViewModel {
    func cartQuantity(for id: String) -> Int {
        coreDataManager.cartQuantity(for: id)
    }

    func addToCart(_ id: String) {
        coreDataManager.addToCart(id)
    }

    func updateCartQuantity(for id: String, to quantity: Int) {
        coreDataManager.updateCartQuantity(for: id, to: quantity)
    }

    func removeFromCart(_ id: String) {
        coreDataManager.removeFromCart(id)
    }
    
    func getCartCount() -> Int {
        coreDataManager.getCartItemCount()
    }
}

// MARK: - Search & Filter

extension ProductListViewModel {
    func updateFilteredProducts(searchText: String? = nil, filter: ProductFilter? = nil) {
        if let searchText = searchText {
            self.searchText = searchText
        }

        if let filter = filter {
            lastAppliedFilter = filter
        }

        var result = products

        // Filter by search
        if !self.searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(self.searchText) }
        }

        // Filter by brand/model
        if let filter = lastAppliedFilter {
            if !filter.selectedBrands.isEmpty {
                result = result.filter { filter.selectedBrands.contains($0.brand) }
            }

            if !filter.selectedModels.isEmpty {
                result = result.filter { filter.selectedModels.contains($0.model) }
            }

            // Sort
            switch filter.sortOption {
            case .oldToNew:
                result.sort { $0.createdAt < $1.createdAt }
            case .newToOld:
                result.sort { $0.createdAt > $1.createdAt }
            case .priceHighToLow:
                result.sort { ($0.price.toDouble ?? 0) > ($1.price.toDouble ?? 0) }
            case .priceLowToHigh:
                result.sort { ($0.price.toDouble ?? 0) < ($1.price.toDouble ?? 0) }
            }
        }

        filteredProducts = result
        onProductsUpdated?()
    }

}

#if DEBUG
extension ProductListViewModel {
    func injectProductsForTesting(_ products: [Product]) {
        self.products = products
        self.filteredProducts = products
    }
}
#endif
