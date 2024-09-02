//
//  Font.swift
//  RestoFlashPOS
//
//  Created by Alexis Contour on 14/12/2023.
//

import Foundation
import UIKit
extension UIFont {
    class func rfFont(ofSize size: CGFloat) -> UIFont {
        var font: UIFont?
        font = UIFont(name: "Rf-Regular", size: size)
        
        if font == nil {
            return UIFont.systemFont(ofSize: size)
        }
        return font!
    }
    
    class func boldRfFont(ofSize size: CGFloat) -> UIFont {
        var font: UIFont?
        font = UIFont(name: "Rf-Bold", size: size)
        
        if font == nil {
            return UIFont.systemFont(ofSize: size)
        }
        return font!
    }
}

func loadFontWith(name: String) {
  let frameworkBundle = Bundle(for: RestoFlashApi.self)
  guard let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "ttf")
    else { return }
  let fontData = NSData(contentsOfFile: pathForResourceString)
  let dataProvider = CGDataProvider(data: fontData!)
  let fontRef = CGFont(dataProvider!)
  var errorRef: Unmanaged<CFError>? = nil

  if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
    NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
  }
}

public func loadRFFonts() {
  loadFontWith(name: "Rf-Regular")
  loadFontWith(name: "Rf-Bold")
}
