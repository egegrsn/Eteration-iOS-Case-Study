//
//  CoreData+CartProduct.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation
import CoreData

@objc(CartProduct)
public class CartProduct: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartProduct> {
        return NSFetchRequest<CartProduct>(entityName: "CartProduct")
    }

    @NSManaged public var productId: String
    @NSManaged public var quantity: Int16
    @NSManaged public var addedAt: Date
}
