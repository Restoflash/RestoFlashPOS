//
//  SettingsController.swift
//  RestoFlash
//
//  Created by Alexis Contour on 04/05/2023.
//

import Foundation
import Eureka
import SwiftUI
public class SettingsController: FormViewController {
    var api : RestoFlashApi!
    var etablissement : Etablissement!
    var completion : Completion<Credentials>!

    public init(api:RestoFlashApi, etablissement_prefill : Etablissement, completion : @escaping(Completion<Credentials>)) {
        super.init(style: .grouped)
        self.modalPresentationStyle = .formSheet
        self.title = "Enregistrer un point de vente"
        self.api = api
        let savedEtablissement = RestoFlashApi.loadEtablissement()
        if savedEtablissement != nil {
            self.etablissement = savedEtablissement
        } else {
            self.etablissement = etablissement_prefill
        }
        self.completion = completion
     
    }
 
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
    }   
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        form +++ Section() {
            $0.header = HeaderFooterView<UIToolbar>(
                .callback {
                    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56))
    
                    toolbar.tintColor = .black
                    let cancelButton = UIBarButtonItem(title: "Annuler", style: .plain, target: self, action:#selector(self.cancel) )
                    
                    //
                    toolbar.setItems([cancelButton], animated: false)
                    return toolbar
                }
            )
        }

        
       /* form +++ Section { section in
            
            var footer = HeaderFooterView(HeaderFooterProvider<UITableViewHeaderFooterView>.class)

            footer.onSetupView = { view, _ in
                view.textLabel?.text = "Associer ce point de vente à un affilié Resto Flash"
                view.textLabel?.textAlignment = .center
                view.textLabel?.textColor = .darkGray
                
            }
            section.footer = footer
        }*/

        form +++ Section("Etablissement")
            <<< TextRow("siret"){ row in
                row.title = "Siret"
                row.placeholder = "14 chiffres"
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 14))
                row.add(rule:RuleMaxLength(maxLength: 14))
                row.validationOptions = .validatesOnChange
                row.cell.textField.keyboardType = .numberPad
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                    if let row = self.form.rowBy(tag:"register")! as? ButtonRow {
                        row.disabled = true
                        row.evaluateDisabled()
                    }
                }
                else
                {
                    if let row = self.form.rowBy(tag:"register")! as? ButtonRow {
                        row.disabled = false
                        row.evaluateDisabled()
                    }
                }
            }
            <<< NameRow("name"){ row in
                row.title = "Nom"
                row.placeholder = "Nom de l'établissement"
            }
        <<< PhoneRow("tel"){
                $0.title = "Téléphone"
                $0.placeholder = ""
            }
        +++ Section()
            <<< LabelRow("status"){
                $0.title = "Le point de vente est enregistré ✅"
                $0.cellStyle = .default
                $0.hidden = .function([]) { form in
                    return RestoFlashApi.loadPOSCredentials() == nil
                }
            }.cellUpdate { cell, _ in
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .darkGray
            }
        <<< ButtonRow("register").onCellSelection { cell, row in
                guard !row.isDisabled else { return }
                self.register()
            }.cellUpdate { cell, row in
                if RestoFlashApi.loadPOSCredentials() == nil {
                    row.title = "Associer cette caisse à l'établissement"
                }
                else
                {
                    row.title = "Déconnecter ce point de vente"
                }
                
            }
        
       /* +++ Section("Options")
            <<< TextRow(){
                $0.title = "Label Reference"
                $0.value = "Table"
            }*/
         // prefill form
        form.setValues(["siret":etablissement.siret, "name":etablissement.name, "tel":etablissement.phone])
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)

    }
    
    func register(){
        if RestoFlashApi.loadPOSCredentials() == nil {
            let values = self.form.values()
            let siret = values["siret"] as? String ?? ""
            let name = values["name"] as? String ?? ""
            let phone = values["tel"] as? String ?? ""
            let etablissement = Etablissement(siret: siret, name: name, phone: phone)
            self.api.registerPOS(etablissement: etablissement) { result in
                switch result {
                case .success(_):
                    try? RestoFlashApi.saveEtablissement(etablissement)
                case .failure(_):
                    break
                }
                self.dismiss(animated: true)  {
                    self.completion(result)
                }
            }
        }
        else {
            try? RestoFlashApi.deletePOSCredentials()
            form.rowBy(tag: "status")?.evaluateHidden()
           // form.rowBy(tag: "register")?.updateCell()
            form.rowBy(tag: "register")?.updateCell()
            tableView?.reloadData()
        }
        
    }
}


class HeaderView : UIToolbar
{
    override init(frame:CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


