//
//  AlertViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 6/30/24.
//

/// Rx
import RxCocoa
import RxSwift

/// Apple
import UIKit

final class AlertVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var baseView: UIView!

    private var alertTitle: String?
    private var alertDetail: String?
    private var alertImage: String?

    private var disposeBag = DisposeBag()
}

// MARK: - View Life Cycle

extension AlertVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - Setting Up UI

extension AlertVC {
    private func setupUI() {
        baseView.layer.cornerRadius = 10
        confirmImageView()
        bind()
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

    private func confirmImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
    }

    private func bind() {
        confirmButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
