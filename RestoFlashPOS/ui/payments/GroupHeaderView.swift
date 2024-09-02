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
    let referenceLabel = UILabel()  // Renamed label
    let totalAmount = UILabel()     // New label for total amount
    var group: GroupedPayments? = nil
    var section: Int = -1
    weak var delegate: PaymentCellDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)

        // Checkbox setup
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.useHapticFeedback = true
        checkbox.uncheckedBorderColor = .darkGray
        checkbox.checkedBorderColor = .darkGray
        checkbox.borderCornerRadius = 4
        checkbox.checkmarkStyle = .tick
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .valueChanged)

        // Reference label setup
        referenceLabel.font = UIFont.boldRfFont(ofSize: 18)
        referenceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Total amount label setup
        totalAmount.font = UIFont.rfFont(ofSize: 16)
        totalAmount.translatesAutoresizingMaskIntoConstraints = false
        totalAmount.textAlignment = .right

        // Add subviews
        addSubview(checkbox)
        addSubview(referenceLabel)
        addSubview(totalAmount)

        // Set up constraints
        NSLayoutConstraint.activate([
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            checkbox.heightAnchor.constraint(equalToConstant: 24),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            
            referenceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),

            totalAmount.centerYAnchor.constraint(equalTo: centerYAnchor),
            totalAmount.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            totalAmount.leadingAnchor.constraint(equalTo: referenceLabel.trailingAnchor, constant: 8),

            heightAnchor.constraint(equalToConstant: 48)  // Height constraint for the header view
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
}

