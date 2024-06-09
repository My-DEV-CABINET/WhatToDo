//
//  Extension+UITextField.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

import UIKit

extension UITextField {
    func underlined(viewSize: CGFloat, color: UIColor) {
        let border = CALayer()
        let width: CGFloat = 1
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height + 10, width: viewSize, height: width)
        border.borderWidth = width
        self.layer.addSublayer(border)
    }
}
