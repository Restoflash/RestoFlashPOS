//
//  PaymentCell.swift
//  RestoFlashPOS
//
//  Created by Alexis Contour on 24/05/2023.
//

import Foundation
import UIKit
import SimpleCheckbox

class PaymentCell: UITableViewCell {
    weak var delegate: PaymentCellDelegate?
    var currentPayment : Payment? = nil
    let checkbox = Checkbox()
    
    let typeImageView = UIImageView()
    let sponsorshipKeyLabel = UILabel()
    let usernameLabel = UILabel()
    let amountLabel = UILabel()
    
    let dateLabel = UILabel()
    let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Checkbox
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.useHapticFeedback = true
        checkbox.uncheckedBorderColor = .darkGray
        checkbox.checkedBorderColor = .darkGray
        checkbox.borderCornerRadius = 4
        checkbox.checkmarkStyle = .tick
        checkbox.borderLineWidth = 1
        checkbox.isChecked = false
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .valueChanged)
        
        
        // First row
        typeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeImageView)
        
        sponsorshipKeyLabel.textColor = .black
        //UIColor(red: 0.99, green: 0.19, blue: 0.19, alpha: 1.0)
        //smaller text font
        sponsorshipKeyLabel.font = UIFont.systemFont(ofSize: 13)
        sponsorshipKeyLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(sponsorshipKeyLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        contentView.addSubview(usernameLabel)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = UIFont.boldSystemFont(ofSize: 17)
        amountLabel.textAlignment = .right
        contentView.addSubview(amountLabel)
        
        // Second row
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(dateLabel)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        statusLabel.layer.cornerRadius = 11
        statusLabel.clipsToBounds = true
        statusLabel.textColor = .black
        statusLabel.font = UIFont.systemFont(ofSize: 11)
        statusLabel.textAlignment = .center          // Added
        statusLabel.isHidden = true
        
        contentView.addSubview(statusLabel)
        
        contentView.addSubview(checkbox)
     
        // Constraints
        NSLayoutConstraint.activate([
            // Checkbox
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -4),
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            checkbox.heightAnchor.constraint(equalToConstant: 30),
            checkbox.widthAnchor.constraint(equalToConstant: 30),

            // First row
            typeImageView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),
            typeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            typeImageView.heightAnchor.constraint(equalToConstant: 20),
            typeImageView.widthAnchor.constraint(equalToConstant: 20),

            sponsorshipKeyLabel.leadingAnchor.constraint(equalTo: typeImageView.trailingAnchor, constant: 4),
            sponsorshipKeyLabel.topAnchor.constraint(equalTo: typeImageView.topAnchor),
            sponsorshipKeyLabel.bottomAnchor.constraint(equalTo: typeImageView.bottomAnchor),
           
            usernameLabel.leadingAnchor.constraint(equalTo: sponsorshipKeyLabel.trailingAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: typeImageView.topAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            usernameLabel.bottomAnchor.constraint(equalTo: typeImageView.bottomAnchor),
           
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            amountLabel.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor),

            // Second row
            dateLabel.leadingAnchor.constraint(equalTo: typeImageView.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            dateLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),

            statusLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            statusLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 86)
        ])


        sponsorshipKeyLabel.setContentHuggingPriority(.required, for: .horizontal)
        sponsorshipKeyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        usernameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        usernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

       // sponsorshipKeyLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
       // usernameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    }
    
    // MARK: - Checkbox state handling
    
    /// Toggles the checkbox state.
    @objc func toggleCheckbox() {
       // checkbox.isSelected = !checkbox.isSelected
        if let delegate = delegate, let currentPayment = currentPayment {
            if checkbox.isChecked {
                delegate.didSelectPayment(currentPayment)
            } else {
                delegate.didDeselectPayment(currentPayment)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setPayment(_ payment : Payment, isChecked : Bool){
        self.currentPayment = payment
        let bundle = Bundle(for: PaymentCell.self)
        let imageURL = bundle.url(forResource:payment.token.tokenType.imageResource, withExtension: "png")!
        let image = UIImage(data: try! Data(contentsOf: imageURL))
//        let image = UIImage(named:payment.token.tokenType.imageResource, in: Bundle(for: PaymentCell.self), with: nil)
        self.typeImageView.image = image?.withRenderingMode(.alwaysTemplate)
        self.typeImageView.tintColor = .black
        self.dateLabel.text = payment.token.formattedDate
        self.amountLabel.text = payment.token.formattedAmount
        self.usernameLabel.text = payment.token.userName
        self.statusLabel.text = payment.result.status
        self.statusLabel.textColor = payment.result.statusTextColor
        self.statusLabel.backgroundColor = payment.result.statusColor
        self.checkbox.isChecked=isChecked
        self.sponsorshipKeyLabel.text = payment.token.displayKey
    }
}

extension TokenResult{
    var statusColor : UIColor {
        switch self {
        case .pending:
            return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        case .success(_):
            //93D976 green
            return UIColor(red: 0.58, green: 0.85, blue: 0.46, alpha: 1.0)
        case .error(_):
            return UIColor(red: 0.85, green: 0.46, blue: 0.46, alpha: 1.0)
        }
    }
    var statusTextColor : UIColor {
        switch self {
        case .pending:
            return .black
        case .success(_):
            return .white
        case .error(_):
            return .white
        }
    }
}
