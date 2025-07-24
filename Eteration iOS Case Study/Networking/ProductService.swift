//
//  ProductService.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts() async throws -> [Product]
}

final class ProductService: ProductServiceProtocol {
    
    func fetchProducts() async throws -> [Product] {
        let urlString = "https://5fc9346b2af77700165ae514.mockapi.io/products"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        return try decoder.decode([Product].self, from: data)
    }
}
