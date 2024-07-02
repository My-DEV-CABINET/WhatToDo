//
//  AlertViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 6/30/24.
//

import UIKit

final class AlertViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var baseView: UIView!

    private var alertTitle: String?
    private var alertDetail: String?
    private var alertImage: String?
}

// MARK: - View Life Cycle

extension AlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
}

// MARK: - Setting Up UI

extension AlertViewController {
    private func setupUI() {
        baseView.layer.cornerRadius = 10
        confirmConfirmButton()
        confirmImageView()
    }

    private func updateUI() {
        titleLabel.text = alertTitle
        detailLabel.text = alertDetail
        if let imageName = alertImage {
            imageView.image = UIImage(systemName: imageName)
        }
    }

    func configure(title: String, detail: String, image: String) {
        alertTitle = title
        alertDetail = detail
        alertImage = image
    }

    private func confirmConfirmButton() {
        confirmButton.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }

    private func confirmImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
    }
}
