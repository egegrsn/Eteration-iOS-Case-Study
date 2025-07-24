//
//  ProductListViewController.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import UIKit

class ProductListViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectFilterButton: UIButton!
    
    private let viewModel = ProductListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollectionView()
        setupSearchUI()
        bindViewModel()
        updateCartTabBadgeCount()
        Task {
            await viewModel.loadProducts()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            guard let self else { return }
            toggleActivityIndicator(isLoading)
            toggleUserInteractions(isLoading)
        }
        
        viewModel.onProductsUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if self.viewModel.numberOfProducts == 0 {
                    self.collectionView.setEmptyMessage("No products found.")
                } else {
                    self.collectionView.restore()
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showAlert(message: message)
            }
        }
    }
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupSearchUI(){
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .gray
        icon.contentMode = .scaleAspectFit
        
        // Container view with padding
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        icon.frame = CGRect(x: 5, y: 0, width: 20, height: 20) // 5pt left padding
        container.addSubview(icon)
        
        searchTextField.leftView = container
        searchTextField.leftViewMode = .always
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
    }
    
    @IBAction func didTapFilterButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let filterVC = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            filterVC.delegate = self
            filterVC.allProducts = viewModel.products
            filterVC.lastAppliedFilter = viewModel.lastAppliedFilter
            navigationController?.pushViewController(filterVC, animated: true)
        }
    }
    
    private func showAlert(title:String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func updateCartTabBadgeCount() {
        let cartBadgeCount = viewModel.getCartCount()
        let badge = cartBadgeCount > 0 ? "\(cartBadgeCount)" : nil
        tabBarController?.tabBar.items?[1].badgeValue = badge
    }
    
    @objc private func searchTextChanged(_ textField: UITextField) {
        let query = textField.text ?? ""
        viewModel.updateFilteredProducts(searchText: query)
    }
    
    private func toggleActivityIndicator(_ isLoading: Bool) {
        activityIndicator.hidesWhenStopped = true
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func toggleUserInteractions(_ isLoading: Bool) {
        searchTextField.isUserInteractionEnabled = !isLoading
        selectFilterButton.isUserInteractionEnabled = !isLoading
    }
}

// MARK: - CollectionView

extension ProductListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfProducts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseIdentifier, for: indexPath) as? ProductCell,
            let product = viewModel.product(at: indexPath.row)
        else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: product, isFavorited: viewModel.isProductFavorited(product.id))
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = viewModel.product(at: indexPath.row) else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            detailsVC.delegate = self
            detailsVC.product = product
            detailsVC.isFavorited = viewModel.isProductFavorited(product.id)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 16 * 2 + 12 // sectionInsets + spacing
        let availableWidth = collectionView.bounds.width - padding
        let widthPerItem = availableWidth / 2

        return CGSize(width: widthPerItem, height: widthPerItem * 1.4) // adjust ratio as needed
    }
}

// MARK: - Delegates

extension ProductListViewController: ProductCellDelegate {
    func didTapAddToCart(for productId: String) {
        viewModel.addToCart(productId)
        updateCartTabBadgeCount()
    }
    
    func didTapAddToFavorite(_ cell: ProductCell, for productId: String) {
        viewModel.toggleFavorite(for: productId)

        if let indexPath = collectionView.indexPath(for: cell) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension ProductListViewController: ProductDetailsDelegate {
    func didTapAddToFavorite(for productId: String) {
        viewModel.toggleFavorite(for: productId)
    }
}

extension ProductListViewController: FilterViewControllerDelegate {
    func didApplyFilter(_ filter: ProductFilter) {
        viewModel.updateFilteredProducts(filter: filter)
    }
}

extension ProductListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}
