//
//  CartCell.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 23.07.2025.
//

import UIKit

protocol CartCellDelegate: AnyObject {
    func didTapPlusButton(_ cell: CartCell, for productId: String)
    func didTapMinusButton(_ cell: CartCell, for productId: String)
}

class CartCell: UITableViewCell {
    
    static let reuseIdentifier = "CartCell"
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    weak var delegate: CartCellDelegate?
    private var productId: String?
    private var quantity: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didTapPlusButton(_ sender: UIButton) {
        if let id = productId {
            delegate?.didTapPlusButton(self, for: id)
        }
        quantity += 1
        quantityLabel.text = "\(quantity)"
    }
    
    @IBAction func didTapMinusButton(_ sender: UIButton) {
        if let id = productId {
            delegate?.didTapMinusButton(self, for: id)
        }
        quantity -= 1
        quantityLabel.text = "\(quantity)"
    }
    
    func configure(with product: Product, quantity: Int) {
        self.quantity = quantity
        self.productId = product.id
        brandLabel.text = product.name
        
        if let price = Double(product.price) {
            priceLabel.text = String(format: "%.2f ₺", price)
        } else {
            priceLabel.text = "₺0.00"
        }
        
        quantityLabel.text = "\(quantity)"
    }
    
}
