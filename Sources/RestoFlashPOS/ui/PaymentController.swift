//
//  PaymentController.swift
//  RestoFlash
//
//  Created by Alexis Contour on 17/04/2023.
//

import Foundation
import UIKit
import SwiftDate
import SwiftUI
import Money
import ProgressHUD

public typealias PaymentClosure = ((PaymentSummary) -> Void)

open class PaymentController : UIViewController, UITableViewDataSource, UITableViewDelegate, PaymentCellDelegate {
    public func didSelectPayment(_ payments: Payment) {
        self.viewModel.paymentSelected(payments)
        updateView()
    }
    
    public func didDeselectPayment(_ payments: Payment) {
        self.viewModel.paymentUnselected(payments)
        updateView()
    }
    
    public func didSelectGroup(_ group: GroupedPayments, section : Int) {
        self.viewModel.paymentGroupSelected(group)
        updateView()
        tableView.reloadData()
    }
    
    public func didDeselectGroup(_ group: GroupedPayments, section : Int) {
        self.viewModel.paymentGroupUnselected(group)
       updateView()
    }
    func updateView() {
        tableView.reloadData()
        updateInfoLabel()
        updatePayButton()
    }
    
    public var messageWhenEmpty : String? = nil

    
    var paymentsGroups : [GroupedPayments]   {
        get {
            viewModel.groupedPayments
        }
    }
    public var paymentCompletion : PaymentClosure?
    public var rfApi : RestoFlashApi?
    public var downloadError : Error? = nil
    
    var viewModel : PaymentsViewModel {
        didSet {
         //   paymentsGroups = viewModel.groupedPayments
            tableView.reloadData()
        }
    }
    
    
    @IBOutlet var progressView : UIActivityIndicatorView!
    //= UIActivityIndicatorView(style: .large)
    @IBOutlet var mainView : UIView!
    @IBOutlet public var tableView : UITableView!
    @IBOutlet var infoLabel : UILabel!
    @IBOutlet var payButton : UIButton!
    @IBOutlet var toolbar : UIToolbar!
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    
    
    init(api:RestoFlashApi?, model : PaymentsViewModel, result : @escaping(PaymentClosure)){
        self.viewModel = model
       // self.paymentsGroups = viewModel.groupedPayments
        self.paymentCompletion = result
        self.rfApi = api
        
        super.init(nibName: nil, bundle: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
            // Customize the iPad size...
            // self.preferredContentSize = CGSize(width: 600, height: 400)
        }
    }
    
    public init?(api:RestoFlashApi, askedAmount: Money<EUR>?, ticketReference : String,  result : @escaping(PaymentClosure)){
        
        if(!api.isPOSInitialized)
        {
            return nil
        }
        self.viewModel = PaymentsViewModel(with:askedAmount,ticketReference:ticketReference, retrievedTokens: [])
       // self.paymentsGroups = viewModel.groupedPayments
        self.paymentCompletion = result
        self.rfApi = api
        
        super.init(nibName: nil, bundle: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
        }
    }
    
    public init?(api:RestoFlashApi, askedAmount: Money<EUR>?, ticketReference : String){
        if(!api.isPOSInitialized)
        {
            return nil
        }
        self.viewModel = PaymentsViewModel(with:askedAmount,ticketReference:ticketReference, retrievedTokens: [])
       // self.paymentsGroups = viewModel.groupedPayments
        self.paymentCompletion = nil
        self.rfApi = api
        
        super.init(nibName: nil, bundle: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
        }
    }


    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfoLabel(){
        if let remainigAmount = viewModel.remainigAmount {
            let text = "Reste à encaisser : \(remainigAmount.formattedString)"
            self.infoLabel.text = text
            self.infoLabel.isHidden = false
        }
        else
        {
            self.infoLabel.isHidden = true
        }
        
    }
    func updatePayButton(){
        self.payButton.isHidden = self.viewModel.selectedAmount == 0
        self.payButton.setTitle("Encaisser \(self.viewModel.selectedAmount.formattedString)", for: .normal)
    }

    @IBAction func pay(_ sender: Any) {
        //viewModel.selectedPayments is a Set
        ProgressHUD.animate("Paiement...")
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
        ProgressHUD.succeed()
        self.dismiss(animated: true ) {
            if let completion = self.paymentCompletion
            {
                completion(summary)
            }
        }
    }

    @IBAction func close(){
        self.dismiss(animated: true)
    }
    
     @IBAction func refreshButton(){
        refresh()
    }
    
    @objc public func refresh() {
        ProgressHUD.animate("Téléchargement...")
        self.retrievePayments { result in
            if result {
                ProgressHUD.succeed()
            }
            else {
                ProgressHUD.failed("Erreur")
            }
            
            self.updateView()
        }
    }
    
    public func refreshSilent() {
        self.retrievePayments { result in
            self.updateView()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        progressView = UIActivityIndicatorView()
        //= UIActivityIndicatorView(style: .large)
        mainView = UIView()
        self.mainView.backgroundColor = .white
        tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
        // Identifiant stable E2E (miroir de fr.restoflash.ui.R.id.payments_list Android) — voir
        // iphone_ben/RestoFlashUITests/.../PaymentReceptionRobot. Aucun impact fonctionnel/visuel.
        tableView.accessibilityIdentifier = "payments_list"
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear

        tableView.backgroundView = nil
        
        if #available(iOS 14.0, *) {
                var bgConfig = UIBackgroundConfiguration.listGroupedCell()
                bgConfig.backgroundColor = UIColor.clear
                //UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
                UITableViewCell.appearance().backgroundConfiguration = bgConfig
            }
        //tableView.isOpaque = false
        //tableView.separatorInset = UIEdgeInsets.zero
        infoLabel = UILabel()
        infoLabel.textAlignment = .center
        //same font than tableview footer (section)
        infoLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        updateInfoLabel()
        payButton = UIButton()
        // Identifiant stable E2E (miroir de fr.restoflash.ui confirm_button Android) : bouton
        // « Encaisser … », masqué tant que rien n'est sélectionné (cf. updatePayButton).
        payButton.accessibilityIdentifier = "confirm_button"

        view.addSubview(progressView)
        //center progress view in parent
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progressView.startAnimating()
        feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator?.prepare()
        
        let installView : (()->Void) = {
            //       self.progressView.stopAnimating()
            //       self.progressView.removeFromSuperview()
            self.view.addSubview(self.mainView)
            if self.navigationController != nil
            {
                let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButton))
                // Identifiant stable E2E (miroir de fr.restoflash.ui.R.id.menu_item_resync Android) :
                // rafraîchit la liste des paiements en attente depuis le BO.
                refreshButton.accessibilityIdentifier = "menu_item_resync"
                self.navigationItem.rightBarButtonItems = [refreshButton]
            }
            else{
                // Add toolbar
                self.toolbar = UIToolbar()
                self.toolbar.items = [
                    UIBarButtonItem(title: "Paiement #\(self.viewModel.ticketReference)", style: .plain, target: nil, action: nil),
                    //flexible
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButton)),
                    UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.close))
                ]
                self.toolbar.tintColor = .black
                
                self.mainView.addSubview(self.toolbar)
                self.toolbar.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.toolbar.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor),
                    self.toolbar.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor),
                    self.toolbar.topAnchor.constraint(equalTo: self.mainView.topAnchor),
                    self.toolbar.heightAnchor.constraint(equalToConstant:56),
                ])
            }
           
            
            // Add tableView
            self.mainView.addSubview(self.tableView)
            self.tableView.register(GroupHeaderView.self, forHeaderFooterViewReuseIdentifier: "GroupHeaderView")
            self.tableView.sectionHeaderHeight = 60
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.tableView.register(PaymentCell.self, forCellReuseIdentifier: "PaymentCell")
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.allowsMultipleSelection = true
 
            
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
            
            
            let topAnchor = (self.toolbar == nil) ? self.view.topAnchor : self.toolbar.bottomAnchor
            
            NSLayoutConstraint.activate([
                self.mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.mainView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                

                
                self.tableView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor),
                self.tableView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor),
                self.tableView.topAnchor.constraint(equalTo: topAnchor),
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
    
    func paymentForIndexPath(_ indexPath : IndexPath) -> Payment{
        let payments = paymentsGroups[indexPath.section].payments
        let payment = payments[indexPath.row]
        return payment
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        //let payments = paymentsGroups[indexPath.section].payments
        let payment = self.paymentForIndexPath(indexPath)
        let isSelected = viewModel.isPaymentSelected(payment)
        cell.isSelected = isSelected
        cell.setPayment(payment, isChecked:isSelected)
        cell.delegate = self
        cell.setSelected(cell.isSelected, animated: true)
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76 // Height of cell
    }
    
    
    
    public  func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.paymentsGroups.count
        if  count == 0 {
            if let error = downloadError {
                self.tableView.setEmptyMessage(error.localizedDescription)
            }
            else {
                if let message = self.messageWhenEmpty {
                    self.tableView.setEmptyMessage(message)
                }
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = .clear
    }

    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GroupHeaderView") as! GroupHeaderView
        let group = paymentsGroups[section]
        headerView.referenceLabel.text = group.group.name
        headerView.section = section
        headerView.group = group
        headerView.checkbox.isChecked = viewModel.isGroupSelected(group)
        headerView.delegate = self

        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let payment = self.paymentForIndexPath(indexPath)
        let wasSelected = viewModel.isPaymentSelected(payment)
        if !wasSelected {
            //toggle change
            didSelectPayment(payment)
            updateView()
        }
        else
        {
            didDeselectPayment(payment)
            updateView()
        }
        // Trigger impact feedback.
        feedbackGenerator?.impactOccurred()

        // Keep the generator in a prepared state.
        feedbackGenerator?.prepare()
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let payment = self.paymentForIndexPath(indexPath)
        let wasSelected = viewModel.isPaymentSelected(payment)
        if wasSelected {
            //toggle change
            didDeselectPayment(payment)
            updateView()
        }
    }
}


extension Token {
    var formattedDate : String
    {
        get {
            let franceRegion = Region(calendar: Calendars.gregorian, zone: Zones.europeParis, locale: Locales.french)
            
            let dateInRegion = DateInRegion(self.date, region: franceRegion)
            // if date is today, display time 14:26 only else display date and time 12 oct 14:26
            if date.isToday {
                return dateInRegion.toString(.relative())
            } else {
                return dateInRegion.toString(.dateTime(.medium))
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





struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        get {
            
            let ctrl =  PaymentController(api:nil,model: paymentsViewModel) { result in
                
            }
            return PaymentControllerView(with: ctrl).environment(\.locale, .init(identifier: "fr"))
        }
    }
    
    static var paymentsViewModel : PaymentsViewModel {
        get {
            let checkouts = try! JSONDecoder().decode([Checkout].self, from: checkouts_list_data)
            let tokens = checkouts.map {Token.checkout(checkout: $0)}
            let paymentViewModel = PaymentsViewModel(with: 26.46, ticketReference: "1233", retrievedTokens: tokens)
            paymentViewModel.dontAutoDownload = true
            return paymentViewModel
        }
    }
}
