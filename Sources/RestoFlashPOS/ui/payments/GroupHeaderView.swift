//
//  GroupHeaderView.swift
//  RestoFlashPOS
//
//  Created by Alexis Contour on 24/05/2023.
//

import Foundation
import UIKit
import SimpleCheckbox

class GroupHeaderView: UITableViewHeaderFooterView {
    let checkbox = Checkbox()
    let label = UILabel()
    var group : GroupedPayments? = nil
    var section : Int = -1
    weak var delegate: PaymentCellDelegate?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        //let image = UIImage(named:"unchecked_checkbox", in: Bundle(for: PaymentCell.self), with: nil)
        self.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.useHapticFeedback = true
        checkbox.uncheckedBorderColor = .darkGray
        checkbox.checkedBorderColor = .darkGray
        checkbox.borderCornerRadius = 4
        checkbox.checkmarkStyle = .tick
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .valueChanged)
        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(checkbox)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            checkbox.heightAnchor.constraint(equalToConstant: 30),
            checkbox.widthAnchor.constraint(equalToConstant: 30),
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 50)  // Add height constraint
        ])
    }
    
    @objc func toggleCheckbox() {
        //checkbox.isSelected = !checkbox.isSelected
        guard let delegate = delegate, let group = group else { return }
        if checkbox.isChecked {
            delegate.didSelectGroup(group, section: section)
          
        } else
        {
            delegate.didDeselectGroup(group, section: section)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
