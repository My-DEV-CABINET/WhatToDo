//
//  SettingViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 7/2/24.
//

/// Apple
import UIKit

final class SettingViewController: UIViewController {
    @IBOutlet weak var backgroundStackView: UIStackView!
    @IBOutlet weak var textStackView: UIStackView!
}

// MARK: - View Life Cycle

extension SettingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backgroundStackView.isLayoutMarginsRelativeArrangement = true

        backgroundStackView.backgroundColor = .systemGray4
        backgroundStackView.layer.cornerRadius = 10

        textStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textStackView.isLayoutMarginsRelativeArrangement = true

        textStackView.backgroundColor = .systemGray4
        textStackView.layer.cornerRadius = 10
    }
}

// MARK: - Setting Up UI

extension SettingViewController {
    private func setupUI() {}
}
