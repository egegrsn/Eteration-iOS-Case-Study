//
//  FilterViewController.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

import UIKit

enum SortOption: Int, CaseIterable {
    case oldToNew = 0
    case newToOld
    case priceHighToLow
    case priceLowToHigh

    var title: String {
        switch self {
        case .oldToNew: return "Old to new"
        case .newToOld: return "New to old"
        case .priceHighToLow: return "Price high to low"
        case .priceLowToHigh: return "Price low to high"
        }
    }
}

struct ProductFilter {
    var sortOption: SortOption
    var selectedBrands: Set<String>
    var selectedModels: Set<String>
}

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilter(_ filter: ProductFilter)
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    private let sectionTitles = ["Sort by", "Brand", "Model"]

    var allProducts: [Product] = []

    private var selectedBrands = Set<String>()
    private var selectedModels = Set<String>()
    
    private var allBrands: [String] = []
    private var filteredBrands: [String] = []

    private var allModels: [String] = []
    private var filteredModels: [String] = []
    
    var lastAppliedFilter: ProductFilter?

    private let sortOptions: [SortOption] = SortOption.allCases
    private var selectedSortIndex = 0
    private var selectedSort: SortOption {
        return sortOptions[selectedSortIndex]
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation(title: "Filter")
        setupTableView()
        extractFilterData()
        applyPreviousFilterIfExists()
    }

    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "FilterListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FilterListCell.reuseIdentifier)
    }

    private func extractFilterData() {
        allBrands = Array(Set(allProducts.map { $0.brand })).sorted()
        filteredBrands = allBrands

        allModels = Array(Set(allProducts.map { $0.model })).sorted()
        filteredModels = allModels
    }
    
    private func applyPreviousFilterIfExists(){
        if let filter = lastAppliedFilter {
            selectedBrands = filter.selectedBrands
            selectedModels = filter.selectedModels
            selectedSortIndex = filter.sortOption.rawValue
        }
    }
    
    func toggleSelection(_ set: inout Set<String>, value: String) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }
    
    @IBAction func didTapFilterButton(_ sender: UIButton) {
        let filter = ProductFilter(
               sortOption: selectedSort,
               selectedBrands: selectedBrands,
               selectedModels: selectedModels
           )

           delegate?.didApplyFilter(filter)
           navigationController?.popViewController(animated: true)
    }
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterListCell.reuseIdentifier, for: indexPath) as? FilterListCell else {
            return UITableViewCell()
        }

        switch indexPath.section {
        case 0: // Sort
            cell.isSingleSelection = true
            let selected = sortOptions[selectedSortIndex]
            let titles = sortOptions.map { $0.title }

            cell.configure(options: titles, selected: [selected.title]) { [weak self, weak cell] selectedTitle in
                guard let self, let cell else { return }

                if let selectedIndex = self.sortOptions.firstIndex(where: { $0.title == selectedTitle }) {
                    self.selectedSortIndex = selectedIndex
                }

                cell.configure(options: titles, selected: [selectedTitle], onToggle: cell.onToggle!)
            }
            return cell

        case 1: // Brand
            cell.isSingleSelection = false
            cell.configure(options: filteredBrands, selected: selectedBrands) { [weak self, weak cell] brand in
                guard let self, let cell else { return }

                self.toggleSelection(&self.selectedBrands, value: brand)
                cell.configure(options: self.filteredBrands, selected: self.selectedBrands, onToggle: cell.onToggle!)
            }
            return cell

        case 2: // Model
            cell.isSingleSelection = false
            cell.configure(options: filteredModels, selected: selectedModels) { [weak self, weak cell] model in
                guard let self, let cell else { return }

                self.toggleSelection(&self.selectedModels, value: model)
                cell.configure(options: self.filteredModels, selected: self.selectedModels, onToggle: cell.onToggle!)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = FilterSectionHeaderView.fromNib()
        let title = sectionTitles[section]
        header.configure(title: title, placeholder: "Search", tag: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1 || section == 2) ? 70 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 || indexPath.section == 2) {
            return 115
        }
        return 150
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 2 else {
            let view = UIView()
            view.backgroundColor = UIColor.lightGray
            return view
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == 2 else {
            return 1
        }
        return 0
    }
}

extension FilterViewController: UITextFieldDelegate {}

