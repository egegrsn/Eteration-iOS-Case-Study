//
//  ProductCell.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import UIKit

protocol ProductCellDelegate: AnyObject {
    func didTapAddToFavorite(_ cell: ProductCell, for productId: String)
    func didTapAddToCart(for productId: String)
}

final class ProductCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ProductCell"
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private let skeletonView = UIView()
    private var shimmerLayer: CAGradientLayer?
    private var loadTask: Task<Void, Never>?
    weak var delegate: ProductCellDelegate?
    
    private var productId: String?
    private var productName: String?
    private var isFavorited: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
    }
    
    func configure(with product: Product, isFavorited: Bool) {
        self.productId = product.id
        self.productName = product.name
        nameLabel.text = product.name
        priceLabel.text = "\(product.price)₺"
        favoriteButton.tintColor = isFavorited ? .systemYellow : .lightGray
        self.isFavorited = isFavorited
        
        guard let url = URL(string: product.image) else {
            productImageView.image = UIImage(systemName: "photo.fill")
            return
        }
        if let cachedImage = ImageLoader.shared.cachedImage(for: url) {
            productImageView.image = cachedImage
            return
        }

        loadTask = Task {
            do {
                let image = try await ImageLoader.shared.loadImage(from: url)
                if !Task.isCancelled {
                    UIView.transition(with: productImageView, duration: 0.25, options: .transitionCrossDissolve) {
                        self.productImageView.image = image
                    }
                }
            } catch {
                if !Task.isCancelled {
                    print("Failed to load image:", error)
                    productImageView.image = UIImage(systemName: "photo.fill")
                }
            }
        }
    }
    
    func toggleFavoriteButton() {
        isFavorited = !isFavorited
        favoriteButton.tintColor = isFavorited ? .systemYellow : .lightGray
    }
    
    @IBAction func didTapFavoriteButton(_ sender: UIButton) {
        toggleFavoriteButton()
        if let productId = productId {
            delegate?.didTapAddToFavorite(self, for: productId)
        }
    }
    
    @IBAction func didTapAddToCartButton(_ sender: UIButton) {
        if let productId = productId {
            delegate?.didTapAddToCart(for: productId)
        }
    }
    
    private func setupShadow() {
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        // Shadow on the cell layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.masksToBounds = false
    }
}
