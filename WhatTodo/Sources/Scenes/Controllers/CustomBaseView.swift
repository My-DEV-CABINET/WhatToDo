//
//  CustomBaseView.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/29/24.
//

import UIKit

@IBDesignable
final class CustomBaseView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    // Shadow Color
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }

    // Shadow Opacity
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    // Shadow Offset
    @IBInspectable var shadowOffset: CGSize = .init(width: 0, height: 0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    // Shadow Radius
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}
