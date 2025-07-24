//
//  CoreData+Product.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation
import CoreData

@objc(ProductEntity)
public class ProductEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }

    @NSManaged public var productId: String
    @NSManaged public var name: String
    @NSManaged public var desc: String
    @NSManaged public var imageUrl: String
    @NSManaged public var price: String
    @NSManaged public var brand: String
    @NSManaged public var model: String
    @NSManaged public var createdAt: Date
}

extension ProductEntity {
    func toDomain() -> Product {
        return Product(
            id: productId,
            name: name,
            description: desc,
            image: imageUrl,
            price: price,
            brand: brand,
            model: model,
            createdAt: convertISOtoString(createdAt)
        )
    }

    func populate(from product: Product) {
        self.productId = product.id
        self.name = product.name
        self.desc = product.description
        self.imageUrl = product.image
        self.price = product.price
        self.brand = product.brand
        self.model = product.model
        self.createdAt = convertStringToISODate(product.createdAt)
    }

    private func convertStringToISODate(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? Date()
    }

    private func convertISOtoString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
