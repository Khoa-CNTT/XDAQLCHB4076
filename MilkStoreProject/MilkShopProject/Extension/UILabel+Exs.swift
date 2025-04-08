//
//  UILabel+Exs.swift
//  i19-Find-My-Phone-Clap
//
//  Created by Dev iOS on 26/3/24.
//

import Foundation
import UIKit

extension UILabel {
    @IBInspectable var fuzzyBold: CGFloat {
        set {
            self.font = UIFont(name: "FuzzyBubbles-Bold", size: newValue)
        }
        get {
            return UIFont.systemFontSize
        }
    }
    
    @IBInspectable var fuzzyRegular: CGFloat {
        set {
            self.font = UIFont(name: "FuzzyBubbles-Regular", size: newValue)
        }
        get {
            return UIFont.systemFontSize
        }
    }
    
    @IBInspectable var montserratSemiBold: CGFloat {
        set {
            self.font = UIFont(name: "Montserrat-SemiBold", size: newValue)
        }
        get {
            return UIFont.systemFontSize
        }
    }
}

@IBDesignable
class StrokeLabel: UILabel {
    @IBInspectable var strokeSize: CGFloat = 0
    @IBInspectable var strokeColor: UIColor = .clear
  
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let textColor = self.textColor
        context?.setLineWidth(self.strokeSize)
        context?.setLineJoin(CGLineJoin.miter)
        context?.setTextDrawingMode(CGTextDrawingMode.stroke)
        self.textColor = self.strokeColor
        super.drawText(in: rect)
        context?.setTextDrawingMode(.fill)
        self.textColor = textColor
        super.drawText(in: rect)
    }
}
