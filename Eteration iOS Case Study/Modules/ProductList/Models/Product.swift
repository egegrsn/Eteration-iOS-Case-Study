//
//  Product.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation

struct Product: Decodable, Hashable {
    let id: String
    let name: String
    let description: String
    let image: String
    let price: String
    let brand: String
    let model: String
    let createdAt: String
}
