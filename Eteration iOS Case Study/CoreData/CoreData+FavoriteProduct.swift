//
//  Product.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation
import CoreData

@objc(FavoriteProduct)
public class FavoriteProduct: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteProduct> {
        return NSFetchRequest<FavoriteProduct>(entityName: "FavoriteProduct")
    }

    @NSManaged public var productId: String
    @NSManaged public var addedAt: Date
}

