//
//  FilterBoxCell.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import UIKit

class FilterBoxCell: UITableViewCell {
    
    static let reuseIdentifier = "FilterBoxCell"
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var onTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with option: String, isSelected: Bool, isSingleSelection: Bool) {
        let checkImage = isSingleSelection ? UIImage(systemName: "circle") : UIImage(systemName: "square")
        let checkImageSelected = isSingleSelection ? UIImage(systemName: "circle.fill") : UIImage(systemName: "square.fill")
        checkButton.setImage(checkImage, for: .normal)
        checkButton.setImage(checkImageSelected, for: .selected)
        checkButton.isSelected = isSelected
        optionLabel.text = option
    }
    
    @IBAction func didTapCheckButton(_ sender: UIButton) {
        onTapped?()
    }
}
