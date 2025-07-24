//
//  ProductDetailsViewController.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 23.07.2025.
//

import UIKit

protocol ProductDetailsDelegate: AnyObject {
    func didTapAddToCart(for productId: String)
    func didTapAddToFavorite(for productId: String)
}

class ProductDetailsViewController: UIViewController {

    var product: Product?
    weak var delegate: ProductDetailsDelegate?
    var isFavorited: Bool = false

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        guard let product else { return }
        
        titleLabel.text = product.name
        descriptionLabel.text = product.description
        priceLabel.text = "\(product.price)₺"
        favoriteButton.tintColor = isFavorited ? .systemYellow : .lightGray

        if let url = URL(string: product.image) {
            Task {
                do {
                    let image = try await ImageLoader.shared.loadImage(from: url)
                    if !Task.isCancelled {
                        UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) {
                            self.imageView.image = image
                        }
                    }
                } catch {
                    if !Task.isCancelled {
                        print("Failed to load image:", error)
                        imageView.image = UIImage(systemName: "photo.fill")
                    }
                }
            }
        }
    }
    
    @IBAction func didTapAddToCartButton(_ sender: UIButton) {
        if let product = product {
            delegate?.didTapAddToCart(for: product.id)
        }
    }
    
    @IBAction func didTapAddToFavoriteButon(_ sender: UIButton) {
        toggleFavoriteButton()
        if let product = product {
            delegate?.didTapAddToFavorite(for: product.id)
        }
    }
    
    func toggleFavoriteButton() {
        isFavorited = !isFavorited
        favoriteButton.tintColor = isFavorited ? .systemYellow : .lightGray
    }
}
