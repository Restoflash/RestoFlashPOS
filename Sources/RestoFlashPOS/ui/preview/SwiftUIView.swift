//
//  SwiftUIView.swift
//  RestoFlash
//
//  Created by Alexis Contour on 17/04/2023.
//

import SwiftUI




public struct PaymentControllerView : UIViewControllerRepresentable
{
    let paymentView : PaymentController
    public init(with paymentView : PaymentController) {
        self.paymentView = paymentView
    }
    
    public func makeUIViewController(context: Context) -> PaymentController {
        return self.paymentView
    }
    
    public func updateUIViewController(_ uiViewController: PaymentController, context: Context) {
        
    }
    
    public typealias UIViewControllerType = PaymentController
    
    
}


// MOCK DATASOURCE

