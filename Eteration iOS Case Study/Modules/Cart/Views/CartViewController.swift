//
//  CartViewController.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import UIKit

final class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var completeOrderButton: UIButton!

    private let viewModel = CartViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        bindViewModel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadCartItems()
    }

    private func setupTableView() {
        let nib = UINib(nibName: "CartCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CartCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func bindViewModel() {
        viewModel.onItemsUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.viewModel.numberOfProducts == 0 {
                    self.tableView.setEmptyMessage("There are no products in your cart. Add some! :)")
                } else {
                    self.tableView.restore()
                }
            }
        }

        viewModel.onTotalPriceUpdated = { [weak self] total in
            guard let self else { return }
            DispatchQueue.main.async {
                self.totalLabel.text = String(format: "%.2f ₺", total)
            }
        }
    }

    @IBAction func completeOrderTapped(_ sender: UIButton) {
        viewModel.completeOrder()
        print("Order Completed.")
    }
    
    private func updateCartTabBadgeCount() {
        let cartBadgeCount = viewModel.getCartCount()
        let badge = cartBadgeCount > 0 ? "\(cartBadgeCount)" : nil
        tabBarController?.tabBar.items?[1].badgeValue = badge
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.orderedProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as? CartCell else {
            return UITableViewCell()
        }
        let product = viewModel.orderedProducts[indexPath.row]
        let quantity = viewModel.cartItems[product] ?? 0
        cell.configure(with: product, quantity: quantity)
        cell.delegate = self
        return cell
    }
}

extension CartViewController: CartCellDelegate {
    func didTapPlusButton(_ cell: CartCell, for productId: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.increaseQuantity(for: indexPath.row)
            updateCartTabBadgeCount()
        }
    }
    
    func didTapMinusButton(_ cell: CartCell, for productId: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.decreaseQuantity(for: indexPath.row)
            updateCartTabBadgeCount()
        }
    }
    
    
}
