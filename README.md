# Eteration iOS Case Study

This is a sample e-commerce app built using **UIKit** and **MVVM** architecture. The app allows users to browse products, apply filters, add items to the cart, and manage favorites. It demonstrates modern development practices including async/await, Core Data, programmatic Auto Layout, and unit testing.

---

## Features

-  **Product List** with infinite scroll and search
-  **Filtering** by brand, model, and sort options (price/date)
-  **Favorite Management** using Core Data
-  **Shopping Cart** with quantity control and order completion
-  **Offline Persistence** with Core Data caching
-  **MVVM Architecture** with testable ViewModels
-  **Unit Tests** for business logic

---

## Screens

- **Product List** – Displays all products with search, infinite scroll, and quick access to cart and favorites
- **Product Detail** – Full product information and add to cart/favorite
- **Filter Page** – Filter by brand/model, sort results
- **Cart Page** – Modify quantities, view total price, and complete orders
- **Favorites** – Lists all favorited items

---

## Tech Stack

- Swift 6
- UIKit
- Core Data
- MVVM
- URLSession (async/await)
- Programmatic Auto Layout
- XCTest for unit testing

---

## Tests

- ViewModel logic (Product list, search, filtering, cart, favorites)
- Mocked services and CoreData
