//
//  PaymentCell.swift
//  RestoFlashPOS
//
//  Created by Alexis Contour on 24/05/2023.
//

import Foundation
import UIKit

let rf_red : UIColor = UIColor(red:0.86, green: 0.18, blue: 0.11, alpha: 1.0)

class PaymentCell: UITableViewCell {
    
    
    weak var delegate: PaymentCellDelegate?
    var currentPayment : Payment? = nil
    let checkbox = Checkbox()
    
    
    //let typeImageView = UIImageView()
    let containerView = UIView()
    let sponsorshipKeyLabel = UILabel()
    let usernameLabel = UILabel()
    let infoLabel = UILabel()
    let separatorLabel = UILabel()
    let dateLabel = UILabel()
    let amountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

        contentView.backgroundColor = .yellow
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Set the backgroundColor of the contentView to clear to allow the shadow to be

        
        
        
        // Checkbox
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.useHapticFeedback = true
        checkbox.uncheckedBorderColor = .darkGray
        checkbox.checkedBorderColor = .darkGray
        checkbox.borderCornerRadius = 4
        checkbox.checkmarkStyle = .tick
        checkbox.borderLineWidth = 1
        checkbox.isChecked = false
        checkbox.isUserInteractionEnabled = false
        //checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .valueChanged)
        containerView.addSubview(checkbox)
        
        // First row
        ///typeImageView.translatesAutoresizingMaskIntoConstraints = false
        //contentView.addSubview(typeImageView)
        
        sponsorshipKeyLabel.textColor = .black
        //UIColor(red: 0.99, green: 0.19, blue: 0.19, alpha: 1.0)
        //smaller text font
       // sponsorshipKeyLabel.font = UIFont.systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            sponsorshipKeyLabel.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        } else {
            // Fallback on earlier versions: Menlo or Courier can be used as a monospaced font
            sponsorshipKeyLabel.font = UIFont(name: "Menlo", size: 13) ?? UIFont(name: "Courier", size: 13)
        }

        sponsorshipKeyLabel.textColor = .darkGray
        sponsorshipKeyLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(sponsorshipKeyLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.boldRfFont(ofSize: 14)
        containerView.addSubview(usernameLabel)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.rfFont(ofSize: 14)
        infoLabel.textAlignment = .right
        containerView.addSubview(infoLabel)
        
        // Second row
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.rfFont(ofSize: 13)
        containerView.addSubview(dateLabel)
        
        separatorLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel.text = "-"
        separatorLabel.textAlignment = .center
        containerView.addSubview(separatorLabel)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        //amountLabel.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        //amountLabel.layer.cornerRadius = 11
        //amountLabel.clipsToBounds = true
        amountLabel.textColor = rf_red
        amountLabel.font = UIFont.boldRfFont(ofSize: 17)
        amountLabel.textColor = rf_red
        amountLabel.textAlignment = .right          // Added
        amountLabel.isHidden = false
        
        let padding  : CGFloat = 6
        
        
        containerView.addSubview(amountLabel)
        
 
     
        // Constraints
        NSLayoutConstraint.activate([
            
            
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-padding),

            // Checkbox
            checkbox.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
            checkbox.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            checkbox.heightAnchor.constraint(equalToConstant: 24),
            checkbox.widthAnchor.constraint(equalToConstant: 24),

            /* First row
            typeImageView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),
            typeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            typeImageView.heightAnchor.constraint(equalToConstant: 20),
            typeImageView.widthAnchor.constraint(equalToConstant: 20),*/

          
            //usernameLabel.leadingAnchor.constraint(equalTo: sponsorshipKeyLabel.trailingAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: infoLabel.leadingAnchor, constant: -8),
            
           

            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            infoLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            infoLabel.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor),

            // Second row
            dateLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: -2),
            //dateLabel.trailingAnchor.constraint(equalTo: sponsorshipKeyLabel.leadingAnchor, constant: -8),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Separator Label Constraints
               separatorLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 4),
               separatorLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
               separatorLabel.widthAnchor.constraint(equalToConstant: 10),

               // Update sponsorshipKeyLabel leading to be after separatorLabel
               sponsorshipKeyLabel.leadingAnchor.constraint(equalTo: separatorLabel.trailingAnchor, constant: 4),

            
          //  sponsorshipKeyLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 4),
            sponsorshipKeyLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            sponsorshipKeyLabel.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
           
           // dateLabel.widthAnchor.constraint(equalToConstant: 100),

            //amountLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            //amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountLabel.centerXAnchor.constraint(equalTo: infoLabel.centerXAnchor, constant: 0),
            amountLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor, constant: -4),
            amountLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor),

          //  amountLabel.widthAnchor.constraint(equalToConstant: 86)
        ])


        ///sponsorshipKeyLabel.setContentHuggingPriority(.required, for: .horizontal)
        //sponsorshipKeyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sponsorshipKeyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        usernameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        usernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Identifiants stables E2E (miroir des ids du SDK Android fr.restoflash.ui) — ciblés par
        // iphone_ben/RestoFlashUITests/.../PaymentReceptionRobot. Aucun impact fonctionnel/visuel.
        // card_container : la carte cliquable = la ligne ; payment_key : le code du checkout
        // (vide pour un QR, cf. Token.displayKey) ; l'état de sélection et le type de token sont
        // exposés en accessibilityValue par setPayment (le checkbox n'est pas interactif).
        containerView.accessibilityIdentifier = "card_container"
        checkbox.accessibilityIdentifier = "checkbox"
        checkbox.isAccessibilityElement = true
        amountLabel.accessibilityIdentifier = "amount"
        sponsorshipKeyLabel.accessibilityIdentifier = "payment_key"
        usernameLabel.accessibilityIdentifier = "name"

       // sponsorshipKeyLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
       // usernameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    }
    
    // MARK: - Checkbox state handling
    
    /// Toggles the checkbox state.
    @objc func toggleCheckbox() {
       // checkbox.isSelected = !checkbox.isSelected
        //notifySelectionChanged()
     //   setSelected(!self.isSelected, animated: false)
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setPayment(_ payment : Payment, isChecked : Bool){
        self.currentPayment = payment
        self.dateLabel.text = payment.token.formattedDate
        self.infoLabel.text = "Encaisser"
        self.infoLabel.textColor = rf_red
        
        //payment.token.formattedAmount
        self.usernameLabel.text = payment.token.userName
        self.amountLabel.text = payment.token.formattedAmount
        //self.amountLabel.text = payment.result.status
        //self.amountLabel.textColor = rf_red
        self.checkbox.isChecked=isChecked
        setSelectionBorder()
        self.sponsorshipKeyLabel.text = payment.token.displayKey

        // État exposé aux tests E2E (le checkbox n'étant pas interactif, on reflète la sélection ;
        // le type distingue la ligne QR — payment_key vide — de la ligne CHECKOUT). Sans impact UI.
        self.checkbox.accessibilityValue = isChecked ? "checked" : "unchecked"
        self.containerView.accessibilityValue = payment.token.tokenType.rawValue   // "QRCODE" | "CHECKOUT"
    }
    
    func setSelectionBorder()
    {
        if checkbox.isChecked {
            // Apply a blue border when the cell is selected
            containerView.layer.borderWidth = 1.0
            containerView.layer.borderColor = UIColor.blue.cgColor
   
           
            // delegate.didSelectPayment(currentPayment)
        } else {
            // Remove the border when the cell is deselected
            containerView.layer.borderWidth = 0
           // notifySelectionChanged()
        }
    }
   /* override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //let wasSelected = checkbox.isChecked
        
       // if wasSelected != selected {
            
            if selected {
                // Apply a blue border when the cell is selected
                containerView.layer.borderWidth = 1.0
                containerView.layer.borderColor = UIColor.blue.cgColor
                checkbox.isChecked = true
               
                // delegate.didSelectPayment(currentPayment)
            } else {
                // Remove the border when the cell is deselected
                containerView.layer.borderWidth = 0
                checkbox.isChecked=false
               // notifySelectionChanged()
            }
      //  }
       
    }*/
}


