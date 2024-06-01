//
//  DetailToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

import UIKit

final class DetailToDoVC: UIViewController {
    @IBOutlet weak var userActionLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var isConfirmSwitch: UISwitch!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    private var viewModel = DetailToDoViewModel()
}

// MARK: - View Life Cycle 관련 모음

extension DetailToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "할일 추가"
        navigationController?.navigationBar.backgroundColor = .systemGray6

        cancelButton.isHidden = true

        setupUI()
    }
}

// MARK: - View UI 설정 관련 모음

extension DetailToDoVC {
    private func setupUI() {
        confirmBackButton()
        confirmEditButton()

        confirmTextField()
    }
}

// MARK: - Bar Button 관련 모음

extension DetailToDoVC {
    private func confirmBackButton() {
        let backButton = UIBarButtonItem()
        backButton.tintColor = .black
        backButton.title = "닫기"
        backButton.target = self
        backButton.action = #selector(didTapBackButton)

        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func didTapBackButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }

    private func confirmEditButton() {
        let editButton = UIBarButtonItem()
        editButton.tintColor = .black
        editButton.title = "Edit"
        editButton.target = self

        navigationItem.rightBarButtonItem = editButton
    }
}

// MARK: - TextField 관련 모음

extension DetailToDoVC {
    private func confirmTextField() {
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16.0, height: 0))
        textField.leftViewMode = .always

        textField.underlined(viewSize: textField.bounds.width, color: UIColor.systemGray5)
    }
}
