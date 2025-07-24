//
//  FilterSectionHeaderView.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import UIKit

class FilterSectionHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    // MARK: - Nib Instantiation
       static func fromNib() -> FilterSectionHeaderView {
           let nib = UINib(nibName: "FilterSectionHeaderView", bundle: nil)
           guard let view = nib.instantiate(withOwner: nil, options: nil).first as? FilterSectionHeaderView else {
               fatalError("Failed to load FilterSectionHeaderView from nib")
           }
           return view
       }

    func configure(title: String, placeholder: String, tag: Int, delegate: UITextFieldDelegate) {
        textField.isHidden = tag == 0 ? true : false
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.tag = tag
        textField.delegate = delegate
        setupSearchUI()
    }
    
    private func setupSearchUI(){
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .gray
        icon.contentMode = .scaleAspectFit
        
        // Container view with padding
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        icon.frame = CGRect(x: 5, y: 0, width: 20, height: 20) // 5pt left padding
        container.addSubview(icon)
        
        textField.leftView = container
        textField.leftViewMode = .always
        
        }
}
