//
//  CartViewModel.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 23.07.2025.
//

import Foundation

final class CartViewModel {
    
    private let service: ProductServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    private(set) var cartItems: [Product:Int] = [:]
    var orderedProducts: [Product] {
        return Array(cartItems.keys).sorted { $0.id < $1.id }
    }
    
    var onItemsUpdated: (() -> Void)?
    var onTotalPriceUpdated: ((Double) -> Void)?
    var totalPrice = 0.0
    
    var numberOfProducts: Int {
        cartItems.count
    }
    
    
    init(service: ProductServiceProtocol = ProductService(),
        coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.service = service
        self.coreDataManager = coreDataManager
    }
    
    func loadCartItems() {
        cartItems = coreDataManager.getProductsInCart()
        onItemsUpdated?()
        calculateTotalCartPrice()
    }
    
    func calculateTotalCartPrice() {
        totalPrice = 0
        for item in cartItems {
            let itemPrice = Double(item.key.price) ?? 0
            totalPrice += itemPrice * Double(item.value)
        }
        onTotalPriceUpdated?(totalPrice)
    }
    
    func increaseQuantity(for index: Int) {
        let product = orderedProducts[index]
        let currentQuantity = cartItems[product] ?? 0
        let newQuantity = currentQuantity + 1

        coreDataManager.updateCartQuantity(for: product.id, to: newQuantity)
        cartItems[product] = newQuantity

        calculateTotalCartPrice()
        onItemsUpdated?()
    }
    
    func decreaseQuantity(for index: Int) {
        let product = orderedProducts[index]
        let currentQuantity = cartItems[product] ?? 0
        
        if currentQuantity <= 1 {
            coreDataManager.removeFromCart(product.id)
            cartItems.removeValue(forKey: product)
        } else {
            let newQuantity = currentQuantity - 1
            coreDataManager.updateCartQuantity(for: product.id, to: newQuantity)
            cartItems[product] = newQuantity
        }
        
        calculateTotalCartPrice()
        onItemsUpdated?()
    }
    
    func getCartCount() -> Int {
        coreDataManager.getCartItemCount()
    }
        
    func completeOrder() {
        for (product, _) in cartItems {
            coreDataManager.removeFromCart(product.id)
        }
        cartItems.removeAll()
        totalPrice = 0
        onItemsUpdated?()
        onTotalPriceUpdated?(totalPrice)
    }
}
