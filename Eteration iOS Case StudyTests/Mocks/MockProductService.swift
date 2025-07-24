//
//  Mocks.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import UIKit
@testable import Eteration_iOS_Case_Study

final class MockProductService: ProductServiceProtocol {
    var mockProducts: [Product] = []

    func fetchProducts() async throws -> [Product] {
        return mockProducts
    }
}

