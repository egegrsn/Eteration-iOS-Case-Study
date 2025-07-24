//
//  MockCoreDataManager.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import Foundation
import UIKit
@testable import Eteration_iOS_Case_Study

final class MockCoreDataManager: CoreDataManagerProtocol {

    // MARK: - Storage

    var savedProducts: [Product] = []
    private(set) var favoriteProductIds: Set<String> = []
    private(set) var cart: [String: Int] = [:] // productId -> quantity

    // MARK: - Product Storage

    func saveContext() {}

    func saveFetchedProducts(_ products: [Product]) {
        savedProducts = products
    }

    func fetchAllProducts() -> [Product] {
        return savedProducts
    }

    func fetchProduct(by id: String) -> Product? {
        return savedProducts.first { $0.id == id }
    }

    // MARK: - Favorites

    func isProductFavorited(_ id: String) -> Bool {
        return favoriteProductIds.contains(id)
    }

    func addToFavorites(_ id: String) {
        favoriteProductIds.insert(id)
    }

    func removeFromFavorites(_ id: String) {
        favoriteProductIds.remove(id)
    }

    func getFavoritedProducts() -> [Product] {
        return savedProducts.filter { favoriteProductIds.contains($0.id) }
    }

    func getAllFavoriteProductIds() -> [String] {
        return Array(favoriteProductIds)
    }

    func getFavoritedProducts(from allProducts: [Product]) -> [Product] {
        return allProducts.filter { favoriteProductIds.contains($0.id) }
    }

    // MARK: - Cart

    func cartQuantity(for id: String) -> Int {
        return cart[id] ?? 0
    }

    func addToCart(_ id: String) {
        cart[id, default: 0] += 1
    }

    func removeFromCart(_ id: String) {
        cart.removeValue(forKey: id)
    }

    func updateCartQuantity(for id: String, to quantity: Int) {
        if quantity <= 0 {
            cart.removeValue(forKey: id)
        } else {
            cart[id] = quantity
        }
    }

    func getProductsInCart() -> [Product: Int] {
        var result: [Product: Int] = [:]
        for (id, qty) in cart {
            if let product = savedProducts.first(where: { $0.id == id }) {
                result[product] = qty
            }
        }
        return result
    }

    func getAllCartItems() -> [CartProduct] {
        return [] // Stubbed if needed
    }

    func getCartItemCount() -> Int {
        return cart.values.reduce(0, +)
    }
}
