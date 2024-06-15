//
//  EditViewController.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 6/14/24.
//

/// Rx
import RxSwift

/// Apple
import UIKit

final class EditViewController: UIViewController {
    /// Label
    @IBOutlet weak var todoLabel: UILabel!

    /// Switch
    @IBOutlet weak var todoSwitch: UISwitch!

    private var backButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!

    var viewModel: EditViewModel!

    /// Edit 이벤트 핸들러
    var eventHandler: ((Bool) -> Void)?
}

// MARK: - View Life Cycle 관련 모음

extension EditViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
}

// MARK: - UI 관련 모음

extension EditViewController {
    private func setupUI() {
        confirmTodoSwitch()
        setupNavigator()
        configure()
    }

    /// Navigator 관련 모음
    private func setupNavigator() {
        confirmNavigationBar()
        confirmEditButton()
        confirmBackButton()
    }

    /// Todo Switch UI
    private func confirmTodoSwitch() {
        todoSwitch.isEnabled = false
    }

    /// 데이터 주입
    private func configure() {
        guard let title = viewModel.todo?.title else { return }
        guard let isDone = viewModel.todo?.isDone else { return }

        todoLabel.text = title
        todoSwitch.isOn = isDone
    }
}

// MARK: - Bind 관련 모음

extension EditViewController {
    private func bind() {
        editButtonBind()
        backButtonBind()
    }

    /// Edit Button 관련 Bind 모음
    private func editButtonBind() {
        editButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.pushAddVC()
            })
            .disposed(by: viewModel.disposeBag)
    }

    /// Back Button 관련 Bind 모음
    private func backButtonBind() {
        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let isUpdate = self?.viewModel.isUpdate else { return }
                self?.navigationController?.dismiss(animated: true)
                self?.eventHandler?(isUpdate)
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - 화면이동 관련 모음

extension EditViewController {
    /// Add 페이지 화면 이동
    private func pushAddVC() {
        let sb: UIStoryboard = .init(name: "ADD", bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: "AddViewController") as? AddViewController else { return }
        vc.viewModel = AddViewModel()
        vc.viewModel.todo = viewModel.todo
        vc.viewModel.userAction = .edit

        /// AddVC EventHandler
        vc.editHandler = { [weak self] newText, newIsDone in
            DispatchQueue.main.async {
                self?.todoLabel.text = newText
                self?.todoSwitch.isOn = newIsDone
                self?.viewModel.isUpdate = true
            }
        }

        let navigationVC = UINavigationController(rootViewController: vc)
        present(navigationVC, animated: true)
    }
}

// MARK: - Navigation 관련 모음

extension EditViewController {
    private func confirmNavigationBar() {
        navigationItem.title = "할일 수정"
        navigationController?.navigationBar.backgroundColor = .systemGray6
    }

    private func confirmBackButton() {
        backButton = UIBarButtonItem()
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
        editButton = UIBarButtonItem()
        editButton.tintColor = .black
        editButton.title = "Edit"
        editButton.target = self

        navigationItem.rightBarButtonItem = editButton
    }
}
