//
//  NewToDoView.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import UIKit

enum Detail {
    case add
    case edit
    case basic

    var defaultTitle: String {
        switch self {
        case .add:
            return "할일 추가"
        case .edit:
            return "할일 수정"
        case .basic:
            return "n/a"
        }
    }

    var placeHolder: String {
        return "할일을 입력해주세요"
    }

    var defaultStr: String {
        return "할일"
    }

    var isDone: String {
        return "완료"
    }
}

final class DetailToDoView: UIViewController {
    private let titleDefaultLabel = UILabel(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let titleTextField = UITextField(frame: .zero)

    private let isDoneLabel = UILabel(frame: .zero)
    private let isDoneSwitch = UISwitch(frame: .zero)

    private let doneButton = UIButton(frame: .zero)

    deinit {
        print("&&&& DetailToDoView Deinitialized")
    }
}

// MARK: - View Life Cycle

extension DetailToDoView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
//        configure(action: <#T##UserAction#>)
    }
}

// MARK: - Setting Up View

extension DetailToDoView {
    private func setupUI() {
        addView()

        configureTitleDefaultLabel()
        configureTitleLabel()
        configureTitleTextField()
        configureIsDoneLabel()
        configureIsDoneSwitch()
        configureDoneButton()
    }

    private func addView() {
        [titleDefaultLabel, titleLabel, titleTextField, isDoneLabel, isDoneSwitch, doneButton].forEach { view.addSubview($0) }
    }

    func configure(action: UserAction) {
        if action == UserAction.add {
            navigationItem.title = Detail.add.defaultTitle
            titleDefaultLabel.text = Detail.add.defaultTitle
            titleLabel.text = Detail.basic.defaultStr
            titleTextField.placeholder = Detail.basic.placeHolder
            isDoneLabel.text = Detail.basic.isDone
            doneButton.setTitle(Detail.basic.isDone, for: .normal)
        }
    }
}

// MARK: - Configure

extension DetailToDoView {
    private func configureTitleDefaultLabel() {
        titleDefaultLabel.translatesAutoresizingMaskIntoConstraints = false

        titleDefaultLabel.font = .systemFont(ofSize: 35, weight: .bold)
        titleDefaultLabel.textColor = .black

        let constraints = [
            titleDefaultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleDefaultLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            titleDefaultLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            titleDefaultLabel.heightAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black

        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: titleDefaultLabel.bottomAnchor, constant: 15),
            titleLabel.leftAnchor.constraint(equalTo: titleDefaultLabel.leftAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 50),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureTitleTextField() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        titleTextField.font = .systemFont(ofSize: 17, weight: .regular)
        titleTextField.textColor = .black

        let constraints = [
            titleTextField.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 15),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            titleTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureIsDoneLabel() {
        isDoneLabel.translatesAutoresizingMaskIntoConstraints = false

        isDoneLabel.font = .systemFont(ofSize: 20, weight: .bold)
        isDoneLabel.textColor = .black

        let constraints = [
            isDoneLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            isDoneLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            isDoneLabel.widthAnchor.constraint(equalToConstant: 50),
            isDoneLabel.heightAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureIsDoneSwitch() {
        isDoneSwitch.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            isDoneSwitch.topAnchor.constraint(equalTo: isDoneLabel.topAnchor),
            isDoneSwitch.bottomAnchor.constraint(equalTo: isDoneLabel.bottomAnchor),
            isDoneSwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            isDoneSwitch.widthAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.topAnchor.constraint(equalTo: isDoneLabel.bottomAnchor, constant: 30),
            doneButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
