//
//  PaymentController.swift
//  RestoFlash
//
//  Created by Alexis Contour on 17/04/2023.
//

import Foundation
import UIKit
import DateHelper
import SwiftUI
import Money
import PKHUD

public typealias PaymentClosure = ((PaymentSummary) -> Void)?

open class PaymentController : UIViewController, UITableViewDataSource, UITableViewDelegate, PaymentCellDelegate {
    func didSelectPayment(_ payments: Payment) {
        self.viewModel.paymentSelected(payments)
        updateView()
    }
    
    func didDeselectPayment(_ payments: Payment) {
        self.viewModel.paymentUnselected(payments)
        updateView()
    }
    
    func didSelectGroup(_ group: GroupedPayments, section : Int) {
        self.viewModel.paymentGroupSelected(group)
        updateView()
    }
    
    func didDeselectGroup(_ group: GroupedPayments, section : Int) {
        self.viewModel.paymentGroupUnselected(group)
       updateView()
    }
    func updateView() {
        tableView.reloadData()
        updateInfoLabel()
        updatePayButton()
    }
    
    
    var paymentsGroups : [GroupedPayments]   {
        get {
            viewModel.groupedPayments
        }
    }
    var closure : PaymentClosure
    var rfApi : RestoFlashApi?
    var downloadError : Error? = nil
    
    open var viewModel : PaymentsViewModel {
        didSet {
         //   paymentsGroups = viewModel.groupedPayments
            tableView.reloadData()
        }
    }
    
    
    @IBOutlet var progressView : UIActivityIndicatorView!
    //= UIActivityIndicatorView(style: .large)
    @IBOutlet var mainView : UIView!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var infoLabel : UILabel!
    @IBOutlet var payButton : UIButton!
    @IBOutlet var toolbar : UIToolbar!
    
    public init(api:RestoFlashApi?, model : PaymentsViewModel, result : (PaymentClosure)){
        self.viewModel = model
       // self.paymentsGroups = viewModel.groupedPayments
        self.closure = result
        self.rfApi = api
        
        super.init(nibName: nil, bundle: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
            // Customize the iPad size...
            // self.preferredContentSize = CGSize(width: 600, height: 400)
        }
        
    }
    
    public convenience init?(api:RestoFlashApi, askedAmount: Money<EUR>, ticketReference : String,  result : (PaymentClosure)){
        
        if(!api.isPOSInitialized)
        {
            return nil
        }
        
        let viewModel = PaymentsViewModel(with:askedAmount,ticketReference:ticketReference, retrievedTokens: [])
        self.init(api:api, model:viewModel, result: result)
        
    }


    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfoLabel(){
        let text = "Reste à encaisser : \(self.viewModel.remainigAmount.formattedString)"
        self.infoLabel.text = text
        
    }
    func updatePayButton(){
        self.payButton.isHidden = self.viewModel.selectedAmount == 0
        self.payButton.setTitle("Encaisser \(self.viewModel.selectedAmount.formattedString)", for: .normal)
    }

    @IBAction func pay(_ sender: Any) {
        HUD.show(.labeledProgress(title: "Paiement...", subtitle: nil))
        let selectedPayments : [Payment] = Array(viewModel.selectedPayments)
        processPayment(remainingPayments:selectedPayments, processedPayments:[])
    }

    func processPayment(remainingPayments : [Payment],  processedPayments : [Payment] ){
        if remainingPayments.count == 0 {
            finishPayment(processedPayments)
            return
        }
        var paymentsCopy = Array(processedPayments)
        
        var car = remainingPayments[0]
        let cdr = Array(remainingPayments[1..<remainingPayments.count])
        self.rfApi!.processPayment(receiptReference: viewModel.ticketReference, token: car.token) { result in
            switch result {
            case .success(let transaction):
                car.result = .success(transaction)
                paymentsCopy.append(car)
                self.processPayment(remainingPayments: cdr, processedPayments: paymentsCopy)
            case .failure(let error):
                car.result = .error(error)
                paymentsCopy.append(car)
                self.processPayment(remainingPayments: cdr, processedPayments: paymentsCopy)
            }
            self.tableView.reloadData()
        }
        
        
        
    }
    
    func finishPayment(_ payments : [Payment]){
        let summary = PaymentSummary(with: viewModel.askedAmount, payments: payments)
        HUD.flash(.success, delay: 0.6)
        self.dismiss(animated: true ) {
            self.closure?(summary)
        }
    }

    @IBAction func close(){
        self.dismiss(animated: true)
    }
    
    @IBAction func refreshButton(){
        HUD.show(.labeledProgress(title: "Téléchargement...", subtitle: nil))
        self.retrievePayments { result in
            if result {
                HUD.flash(.success, delay: 1.0)
            }
            else {
                HUD.flash(.error, delay: 1.0)
            }
            
            self.updateView()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        progressView = UIActivityIndicatorView()
        //= UIActivityIndicatorView(style: .large)
        mainView = UIView()
        self.mainView.backgroundColor = .white
        tableView = UITableView()
        infoLabel = UILabel()
        infoLabel.textAlignment = .center
        //same font than tableview footer (section)
        infoLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        updateInfoLabel()
        payButton = UIButton()
        toolbar = UIToolbar()
        view.addSubview(progressView)
        //center progress view in parent
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progressView.startAnimating()
        
        let installView : (()->Void) = {

            self.view.addSubview(self.mainView)
            let closeButton : UIBarButtonItem
            if #available(iOS 13, *) {
                 closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.close))
            } else {
                 closeButton = UIBarButtonItem(image: UIImage(named: "close_button"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(self.close))
   
            }
            // Add toolbar
            self.toolbar.items = [
                UIBarButtonItem(title: "Paiement #\(self.viewModel.ticketReference)", style: .plain, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButton)),
                closeButton
            ]
            self.toolbar.tintColor = .black
            
            self.mainView.addSubview(self.toolbar)
            
            // Add tableView
            self.mainView.addSubview(self.tableView)
            self.tableView.register(GroupHeaderView.self, forHeaderFooterViewReuseIdentifier: "GroupHeaderView")
            self.tableView.sectionHeaderHeight = 60
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.tableView.register(PaymentCell.self, forCellReuseIdentifier: "PaymentCell")
            self.tableView.dataSource = self
            self.tableView.delegate = self
            
            // Add £infoLabel and payButton
            self.mainView.addSubview(self.infoLabel)
            
            self.mainView.addSubview(self.payButton)
            //self.payButton.backgroundColor = .systemBlue
            //set background color for state normal
            self.payButton.setBackgroundColor(.systemBlue, for: .normal)
            self.updatePayButton()
            // add action
            self.payButton.addTarget(self, action: #selector(self.pay), for: .touchUpInside)
            //bold title

            // Add constraints
            self.mainView.translatesAutoresizingMaskIntoConstraints = false
            /*
             mainView = UIView()
             tableView = UITableView()
             infoLabel = UILabel()
             payButton = UIButton()
             toolbar = UIToolbar()*/
            
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
            self.payButton.translatesAutoresizingMaskIntoConstraints = false
            self.toolbar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.mainView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                
                self.toolbar.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor),
                self.toolbar.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor),
                self.toolbar.topAnchor.constraint(equalTo: self.mainView.topAnchor),
                self.toolbar.heightAnchor.constraint(equalToConstant:56),
                
                self.tableView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor),
                self.tableView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor),
                self.tableView.topAnchor.constraint(equalTo: self.toolbar.bottomAnchor),
                self.tableView.bottomAnchor.constraint(equalTo: self.infoLabel.topAnchor),
                self.payButton.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 8),
                self.payButton.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -8),
                //bottom constraint to safe area
                self.payButton.bottomAnchor.constraint(equalTo: self.infoLabel.topAnchor, constant: -16),
                self.payButton.heightAnchor.constraint(equalToConstant: 56),
                self.infoLabel.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 8),
                self.infoLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -8),
                //bottom constraint to safe area
                self.infoLabel.bottomAnchor.constraint(equalTo: self.mainView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
                self.infoLabel.heightAnchor.constraint(equalToConstant: 16)
                
            ])
            
            /*   NSLayoutConstraint.activate([
             self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
             self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
             self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
             self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
             ])
             */
        }
        
        if viewModel.dontAutoDownload{
            installView()
        }
        else
        {
            retrievePayments { success in
                installView()
                
            }
        }
        
        
    }
    
    public func retrievePayments(completion: @escaping((Bool) -> Void)){
        downloadError = nil
        rfApi!.downloadCheckouts { result in
            switch result {
            case .success(let checkouts):
                let tokens = checkouts.map {Token.checkout(checkout: $0)}
                self.viewModel.replaceRetrievedTokens(tokens: tokens)
                completion(true)
                self.tableView.reloadData()
            case .failure(let error):
                self.downloadError = error
                completion(false)
                self.tableView.reloadData()
            }
        }
       
    }
    
    func addManualToken(token: Token){
        viewModel.addManualToken(token: token)
        self.tableView.reloadData()
    }
    public func addQrCode(code : String) throws{
        let qrCode  = try QrCode(with: code)
        addManualToken(token: Token.qrCode(qrCode: qrCode))
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count =  paymentsGroups[section].payments.count
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        let payments = paymentsGroups[indexPath.section].payments
        let payment = payments[indexPath.row]
        let isSelected = viewModel.isPaymentSelected(payment)
        cell.setPayment(payment, isChecked:isSelected)
        cell.delegate = self
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64 // Height of cell
    }
    
    
    
    public  func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.paymentsGroups.count
        if  count == 0 {
            if let error = downloadError {
                self.tableView.setEmptyMessage(error.localizedDescription)
            }
            else {
                self.tableView.setEmptyMessage("Aucun paiement en attente")
            }
               
           } else {
               self.tableView.restore()
           }
        return count
    }
    
    //   public  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //     return paymentsGroups[section].group.name  // Use section title for header
    //}
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let group = self.paymentsGroups
        if group.count == 1 && group[0].group == .unspecified {
            return 0  // Hide header
        }
        else
        {
            return 50
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GroupHeaderView") as! GroupHeaderView
        let group = paymentsGroups[section]
        headerView.label.text = group.group.name
        headerView.section = section
        headerView.group = group
        headerView.checkbox.isChecked = viewModel.isGroupSelected(group)
        headerView.delegate = self

        
        return headerView
    }
}


extension Token {
    var formattedDate : String
    {
        get {
            if date.compare(.isToday) {
                return date.toString(dateStyle: .medium, timeStyle: .medium, isRelative: true) ?? ""
            } else {
                return self.date.toString(style: .medium) ?? ""
            }
        }
    }
    var formattedAmount : String
    {
        return "\(self.amount)€"
    }
}

extension TokenType {
    var imageResource : String {
        get {
            switch self
            {
            case .qrCode:
                return "token_type_qr"
            case .checkout:
                return "token_type_checkout"
            }
        }
    }
}


