//
//  HeaderView.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 6/9/24.
//

import UIKit

final class HeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        dateLabel.adjustsFontSizeToFitWidth = true
    }
}
