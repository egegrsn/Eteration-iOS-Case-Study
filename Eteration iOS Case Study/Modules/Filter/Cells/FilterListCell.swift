//
//  FilterListCell.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import UIKit

class FilterListCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!

    static let reuseIdentifier = "FilterListCell"

    var options: [String] = []
    var selectedOptions: Set<String> = []
    var onToggle: ((String) -> Void)?
    var isSingleSelection: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = true
        tableView.bounces = true
        
        let nib = UINib(nibName: "FilterBoxCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FilterBoxCell.reuseIdentifier)
    }

    func configure(options: [String], selected: Set<String>, onToggle: @escaping (String) -> Void) {
        self.options = options
        self.selectedOptions = selected
        self.onToggle = onToggle
        tableView.reloadData()
    }
}

extension FilterListCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterBoxCell.reuseIdentifier, for: indexPath) as? FilterBoxCell else {
            return UITableViewCell()
        }
        let isSelected = selectedOptions.contains(option)
        cell.configure(with: option, isSelected: isSelected, isSingleSelection: isSingleSelection)
        
        
        cell.onTapped = { [weak self] in
            guard let self else { return }
            self.onToggle?(option)
        }
        
        return cell
    }
}
