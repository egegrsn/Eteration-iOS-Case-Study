//
//  CoreDataManager.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation
import CoreData

import Foundation

protocol CoreDataManagerProtocol {
    // Context Saving
    func saveContext()

    // MARK: - Product Storage
    func saveFetchedProducts(_ products: [Product])
    func fetchAllProducts() -> [Product]
    func fetchProduct(by id: String) -> Product?

    // MARK: - Favorites
    func isProductFavorited(_ id: String) -> Bool
    func addToFavorites(_ id: String)
    func removeFromFavorites(_ id: String)
    func getFavoritedProducts() -> [Product]
    func getAllFavoriteProductIds() -> [String]
    func getFavoritedProducts(from allProducts: [Product]) -> [Product]

    // MARK: - Cart
    func cartQuantity(for id: String) -> Int
    func addToCart(_ id: String)
    func removeFromCart(_ id: String)
    func updateCartQuantity(for id: String, to quantity: Int)
    func getProductsInCart() -> [Product: Int]
    func getAllCartItems() -> [CartProduct]
    func getCartItemCount() -> Int
}

final class CoreDataManager: CoreDataManagerProtocol {

    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Eteration_iOS_Case_Study") // Your .xcdatamodeld file name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data Save Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Product Storage

extension CoreDataManager {
    func saveFetchedProducts(_ products: [Product]) {
        for product in products {
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            request.predicate = NSPredicate(format: "productId == %@", product.id)

            let matches = (try? context.fetch(request)) ?? []
            let entity = matches.first ?? ProductEntity(context: context)
            entity.populate(from: product)
        }
        saveContext()
    }

    func fetchAllProducts() -> [Product] {
        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        let results = (try? context.fetch(request)) ?? []
        return results.map { $0.toDomain() }
    }

    func fetchProduct(by id: String) -> Product? {
        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return (try? context.fetch(request).first)?.toDomain()
    }
}

// MARK: - Favorites

extension CoreDataManager {
    
    func isProductFavorited(_ id: String) -> Bool {
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", id)
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func addToFavorites(_ id: String) {
        guard !isProductFavorited(id) else { return }
        
        let fav = FavoriteProduct(context: context)
        fav.productId = id
        fav.addedAt = Date()
        saveContext()
    }
    
    func removeFromFavorites(_ id: String) {
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", id)
        if let result = try? context.fetch(request).first {
            context.delete(result)
            saveContext()
        }
    }
    
    func getFavoritedProducts() -> [Product] {
        // 1. Fetch FavoriteProduct entries
        let favoriteRequest: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        favoriteRequest.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        
        guard let favoriteEntries: [FavoriteProduct] = try? context.fetch(favoriteRequest), !favoriteEntries.isEmpty else {
            return []
        }
        
        // 2. Build map of productId -> addedAt
        let favoriteMap: [String: Date] = Dictionary(uniqueKeysWithValues: favoriteEntries.map { favorite in
            (favorite.productId, favorite.addedAt)
        })
        
        let favoriteIds = Array(favoriteMap.keys)
        
        // 3. Fetch products from ProductEntity
        let productRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        productRequest.predicate = NSPredicate(format: "productId IN %@", favoriteIds)
        
        guard let matchedProducts: [ProductEntity] = try? context.fetch(productRequest) else {
            return []
        }
        
        // 4. Sort using addedAt from favoriteMap
        let sortedProducts = matchedProducts.sorted { (first: ProductEntity, second: ProductEntity) -> Bool in
            guard
                let firstDate = favoriteMap[first.productId],
                let secondDate = favoriteMap[second.productId]
            else {
                return false
            }
            return firstDate < secondDate
        }
        
        return sortedProducts.map { $0.toDomain() }
    }
    
    func getAllFavoriteProductIds() -> [String] {
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        
        do {
            let favorites = try context.fetch(request)
            return favorites.map { $0.productId }
        } catch {
            print("Failed to fetch favorite products: \(error)")
            return []
        }
    }
    
    func getFavoritedProducts(from allProducts: [Product]) -> [Product] {
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        
        do {
            let favorites = try context.fetch(request)
            let favoriteIds = Set(favorites.map { $0.productId })
            print(favoriteIds)
            return allProducts.filter { favoriteIds.contains($0.id) }
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }
}

// MARK: - Cart

extension CoreDataManager {

    func cartQuantity(for id: String) -> Int {
        let request: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", id)
        let item = try? context.fetch(request).first
        return item.map { Int($0.quantity) } ?? 0
    }

    func addToCart(_ id: String) {
        let request: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", id)

        if let item = try? context.fetch(request).first {
            item.quantity += 1
        } else {
            let newItem = CartProduct(context: context)
            newItem.productId = id
            newItem.quantity = 1
            newItem.addedAt = Date()
        }
        saveContext()
    }

    func removeFromCart(_ id: String) {
        let request: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", id)
        if let item = try? context.fetch(request).first {
            context.delete(item)
            saveContext()
        }
    }

    func updateCartQuantity(for id: String, to quantity: Int) {
        guard quantity >= 0 else { return }

        let request: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", id)

        if let item = try? context.fetch(request).first {
            if quantity == 0 {
                context.delete(item)
            } else {
                item.quantity = Int16(quantity)
            }
        } else if quantity > 0 {
            let newItem = CartProduct(context: context)
            newItem.productId = id
            newItem.quantity = Int16(quantity)
            newItem.addedAt = Date()
        }
        saveContext()
    }
    
    func getProductsInCart() -> [Product: Int] {
        let cartRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
        cartRequest.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]

        guard let cartEntries = try? context.fetch(cartRequest), !cartEntries.isEmpty else {
            return [:]
        }

        var cartMap: [String: (quantity: Int, addedAt: Date)] = [:]
        for entry in cartEntries {
                cartMap[entry.productId] = (Int(entry.quantity), entry.addedAt)
        }

        let productIds = Array(cartMap.keys)
        let productRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        productRequest.predicate = NSPredicate(format: "productId IN %@", productIds)

        guard let productEntities = try? context.fetch(productRequest) else {
            return [:]
        }

        let sortedProducts = productEntities.sorted {
            guard
                let firstDate = cartMap[$0.productId]?.addedAt,
                let secondDate = cartMap[$1.productId]?.addedAt
            else {
                return false
            }
            return firstDate < secondDate
        }

        var result: [Product: Int] = [:]
        for productEntity in sortedProducts {
            if let quantity = cartMap[productEntity.productId]?.quantity {
                result[productEntity.toDomain()] = quantity
            }
        }

        return result
    }

    func getAllCartItems() -> [CartProduct] {
        let request: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func getCartItemCount() -> Int {
        let request: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()

        guard let results = try? context.fetch(request) else {
            return 0
        }

        return results.reduce(0) { $0 + Int($1.quantity) }
    }
}
