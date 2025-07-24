//
//  ProductListViewModelTests.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import XCTest
@testable import Eteration_iOS_Case_Study

final class ProductListViewModelTests: XCTestCase {
    
    var viewModel: ProductListViewModel!
    var mockService: MockProductService!
    var mockCoreData: MockCoreDataManager!

    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        mockCoreData = MockCoreDataManager()
        viewModel = ProductListViewModel(service: mockService, coreDataManager: mockCoreData)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockCoreData = nil
        super.tearDown()
    }

    func testLoadProducts_success() async {
        // Given
        let expectation = expectation(description: "products updated")
        mockService.mockProducts = [
            Product(id: "1", name: "Mock", description: "", image: "", price: "100", brand: "B1", model: "M1", createdAt: "2021-01-01")
        ]
        viewModel.onProductsUpdated = {
            expectation.fulfill()
        }

        // When
        await viewModel.loadProducts()
        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.numberOfProducts, 1)
        XCTAssertEqual(viewModel.filteredProducts.first?.name, "Mock")
        XCTAssertEqual(mockCoreData.savedProducts.count, 1)
    }

    func testUpdateFilteredProducts_searchOnly() {
        // Given
        mockCoreData.savedProducts = [
            Product(id: "1", name: "iPhone", description: "", image: "", price: "1000", brand: "Apple", model: "14", createdAt: "2022-01-01"),
            Product(id: "2", name: "Galaxy", description: "", image: "", price: "900", brand: "Samsung", model: "S21", createdAt: "2022-01-02")
        ]
        viewModel = ProductListViewModel(service: mockService, coreDataManager: mockCoreData)

        viewModel.injectProductsForTesting(mockCoreData.savedProducts)
        viewModel.updateFilteredProducts(searchText: "galaxy")

        // Then
        XCTAssertEqual(viewModel.filteredProducts.count, 1)
        XCTAssertEqual(viewModel.filteredProducts.first?.name, "Galaxy")
    }

    func testUpdateFilteredProducts_withFilterAndSort() {
        // Given
        mockCoreData.savedProducts = [
            Product(id: "1", name: "iPhone", description: "", image: "", price: "1000", brand: "Apple", model: "14", createdAt: "2023-01-01"),
            Product(id: "2", name: "Galaxy", description: "", image: "", price: "800", brand: "Samsung", model: "S21", createdAt: "2022-01-01"),
            Product(id: "3", name: "Pixel", description: "", image: "", price: "600", brand: "Google", model: "6", createdAt: "2021-01-01")
        ]
        
        viewModel = ProductListViewModel(service: mockService, coreDataManager: mockCoreData)
        
        viewModel.injectProductsForTesting(mockCoreData.savedProducts)
        viewModel.updateFilteredProducts() // set initial state

        let filter = ProductFilter(
            sortOption: .priceLowToHigh,
            selectedBrands: ["Samsung", "Google"],
            selectedModels: []
        )

        // When
        viewModel.updateFilteredProducts(filter: filter)

        // Then
        XCTAssertEqual(viewModel.filteredProducts.count, 2)
        XCTAssertEqual(viewModel.filteredProducts.first?.name, "Pixel")
        XCTAssertEqual(viewModel.filteredProducts.last?.name, "Galaxy")
    }
   
}

// MARK: - Favorite

extension ProductListViewModelTests {
    func testToggleFavorite() {
        // Given
        let id = "123"
        XCTAssertFalse(mockCoreData.isProductFavorited(id))

        // When
        viewModel.toggleFavorite(for: id)
        XCTAssertTrue(mockCoreData.isProductFavorited(id))

        // When again
        viewModel.toggleFavorite(for: id)
        XCTAssertFalse(mockCoreData.isProductFavorited(id))
    }
    
    func testIsProductFavorited_true() {
        mockCoreData.addToFavorites("1")
        XCTAssertTrue(viewModel.isProductFavorited("1"))
    }

    func testIsProductFavorited_false() {
        XCTAssertFalse(viewModel.isProductFavorited("non-fav"))
    }
    
    func testFavoritedProducts_returnsCorrectSubset() {
        // Given
        mockCoreData.savedProducts = [
            Product(id: "1", name: "Mac", description: "", image: "", price: "100", brand: "Apple", model: "M1", createdAt: "2021-01-01"),
            Product(id: "2", name: "Dell", description: "", image: "", price: "100", brand: "Dell", model: "XPS", createdAt: "2021-01-01")
        ]
        mockCoreData.addToFavorites("1")
        viewModel.injectProductsForTesting(mockCoreData.savedProducts)
        // When
        let favorites = viewModel.favoritedProducts
        
        // Then
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.id, "1")
    }
    
}

// MARK: - Cart

extension ProductListViewModelTests {
    func testAddToCart_incrementsCart() {
        // Given
        let productId = "1"
        
        // When
        viewModel.addToCart(productId)
        
        // Then
        XCTAssertEqual(mockCoreData.cartQuantity(for: productId), 1)
        
        viewModel.addToCart(productId)
        XCTAssertEqual(mockCoreData.cartQuantity(for: productId), 2)
    }

    func testRemoveFromCart_deletesCartItem() {
        // Given
        let productId = "1"
        mockCoreData.addToCart(productId)
        XCTAssertEqual(mockCoreData.cartQuantity(for: productId), 1)
        
        // When
        viewModel.removeFromCart(productId)
        
        // Then
        XCTAssertEqual(mockCoreData.cartQuantity(for: productId), 0)
    }

    func testUpdateCartQuantity_setsCorrectValue() {
        // Given
        let productId = "1"
        
        // When
        viewModel.updateCartQuantity(for: productId, to: 5)
        
        // Then
        XCTAssertEqual(mockCoreData.cartQuantity(for: productId), 5)
        
        // When updated to 0, item should be removed
        viewModel.updateCartQuantity(for: productId, to: 0)
        XCTAssertEqual(mockCoreData.cartQuantity(for: productId), 0)
    }

    func testCartQuantity_returnsCorrectValue() {
        mockCoreData.updateCartQuantity(for: "5", to: 3)
        XCTAssertEqual(viewModel.cartQuantity(for: "5"), 3)
    }

    func testGetCartCount_returnsTotal() {
        mockCoreData.updateCartQuantity(for: "1", to: 2)
        mockCoreData.updateCartQuantity(for: "2", to: 3)
        XCTAssertEqual(viewModel.getCartCount(), 5)
    }

}
