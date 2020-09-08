//
//  FilterViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 07/09/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    
    
    // MARK: - Properties
    let ud = UserDefaults.standard
    
    var arraySelectedCategories: [Category : Bool] = {
        var array: [Category : Bool]  = [:]
        
        Category.allCases.forEach {
            (category) in
            array[category] = false
        }
        
        return array
    }()
    
    let stackView: () -> UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.alignment = UIStackView.Alignment.leading
        stack.spacing = 15.0
        return stack
    }
    
    var categoryButton: (Category) -> UIButton = {
        category in
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        button.setTitle(category.rawValue, for: .normal)
        button.setTitleColor(UIColor.MyPalette.charcoal, for: .normal)
        button.addTarget(self, action: #selector(clickCategoryButton(sender:)), for: .touchUpInside)
        button.tag = Category.getIntFromCategory(category)
        
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sv = stackView()
        
        if ud.bool(forKey: "filter") {
            for (category, _) in self.arraySelectedCategories {
                self.arraySelectedCategories.updateValue(ud.bool(forKey: category.rawValue), forKey: category)
            }
        }
        
        Category.allCases.forEach {
            (category) in
            let button = categoryButton(category)
            
            if let selectedCategory = self.arraySelectedCategories[category], selectedCategory {
                button.isSelected = true
            }
            
            sv.addArrangedSubview(button)
        }
        
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(sv)
        
        // Constraints
        sv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        sv.topAnchor.constraint(equalTo: self.categoryLabel.bottomAnchor, constant: 30).isActive = true
    }
    
    @objc func clickCategoryButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if let category = Category(id: sender.tag) {
            if sender.isSelected {
                self.arraySelectedCategories.updateValue(true, forKey: category)
            } else {
                self.arraySelectedCategories.updateValue(false, forKey: category)
            }
        }
    }
    
    @IBAction func applyFilterAction(_ sender: Any) {
        self.arraySelectedCategories.forEach {
            (key: Category, value: Bool) in
            
            ud.set(value, forKey: key.rawValue)
        }
        
        ud.set(true, forKey: "filter")
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.arraySelectedCategories.forEach {
            (key: Category, value: Bool) in
            
            self.arraySelectedCategories.updateValue(false, forKey: key)
            ud.set(false, forKey: key.rawValue)
        }
        
        ud.set(false, forKey: "filter")
    }
    
}
