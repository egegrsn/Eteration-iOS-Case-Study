//
//  FavoriteProductsViewController.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import UIKit

class FavoriteProductsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = FavoriteProductsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollectionView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavoritedProducts()
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
    
    private func bindViewModel() {
        viewModel.onFavoritesUpdated = { [weak self] in
            guard let self else { return }
            print(viewModel.numberOfItems())
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showAlert(message: message)
            }
        }
    }
    
    private func showAlert(title:String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

extension FavoriteProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseIdentifier, for: indexPath) as? ProductCell,
            let product = viewModel.favoritedProduct(at: indexPath.row)
        else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: product, isFavorited: true)
        cell.delegate = self
        return cell
    }
}

extension FavoriteProductsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 16 * 2 + 12 // sectionInsets + spacing
        let availableWidth = collectionView.bounds.width - padding
        let widthPerItem = availableWidth / 2

        return CGSize(width: widthPerItem, height: widthPerItem * 1.4) // adjust ratio as needed
    }
}

extension FavoriteProductsViewController: ProductCellDelegate {
    func didTapAddToCart(for productId: String) {}
    
    func didTapAddToFavorite(_ cell: ProductCell, for productId: String) {
        viewModel.toggleFavorite(for: productId)
        collectionView.reloadData()
    }
}
