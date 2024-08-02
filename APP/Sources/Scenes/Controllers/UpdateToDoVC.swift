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

final class UpdateToDoVC: UIViewController {
    /// Label
    @IBOutlet weak var todoLabel: UILabel!

    /// Switch
    @IBOutlet weak var todoSwitch: UISwitch!

    private var backButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    private var deleteButton: UIBarButtonItem!

    var viewModel: EditViewModel!

    /// Edit 이벤트 핸들러
    var eventHandler: ((Bool) -> Void)?
    /// Delete 이벤트 핸들러
    var deleteHandler: ((Bool) -> Void)?
}

// MARK: - View Life Cycle 관련 모음

extension UpdateToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.disposeBag = DisposeBag()
    }
}

// MARK: - UI 관련 모음

extension UpdateToDoVC {
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
        confirmDeleteButton()

        navigationItem.rightBarButtonItems = [deleteButton, editButton]
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

extension UpdateToDoVC {
    private func bind() {
        editButtonBind()
        backButtonBind()
        deleButtonBind()
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
                self?.navigationController?.popViewController(animated: true)
                self?.eventHandler?(isUpdate)
            })
            .disposed(by: viewModel.disposeBag)
    }

    private func deleButtonBind() {
        deleteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.showMessageAlert(title: "삭제 알림", message: "삭제하시겠습니까?", completion: {
                    self?.navigationController?.dismiss(animated: true)
                    self?.deleteHandler?(true)
                })
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - 화면이동 관련 모음

extension UpdateToDoVC {
    /// Add 페이지 화면 이동
    private func pushAddVC() {
        let sb: UIStoryboard = .init(name: "Add", bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: "AddViewController") as? CreateToDoVC else { return }
        vc.viewModel = AddViewModel()
        vc.viewModel.todo = viewModel.todo
        vc.viewModel.userAction = .edit

        /// AddVC EventHandler
        vc.editHandler = { [weak self] newText, newIsDone in
            DispatchQueue.main.async {
                self?.todoLabel.text = newText
                self?.todoSwitch.isOn = newIsDone
                self?.viewModel.isUpdate = true

                /// View Model 의 todo 동기화
                self?.viewModel.todo?.title = newText
                self?.viewModel.todo?.isDone = newIsDone
            }
        }

        let navigationVC = UINavigationController(rootViewController: vc)
        present(navigationVC, animated: true)
    }
}

// MARK: - Navigation 관련 모음

extension UpdateToDoVC {
    private func confirmNavigationBar() {
        navigationItem.title = viewModel.todo?.id?.description
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
        editButton.title = "편집"
        editButton.target = self
    }

    private func confirmDeleteButton() {
        deleteButton = UIBarButtonItem()
        deleteButton.tintColor = .black
        deleteButton.image = UIImage(systemName: "trash")
    }
}

// MARK: - 예외처리 알림

extension UpdateToDoVC {
    /// 확인, 취소 존재하는 Alert
    private func showMessageAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAlert = UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        }

        let cancelAlert = UIAlertAction(title: "취소", style: .destructive)

        alert.addAction(confirmAlert)
        alert.addAction(cancelAlert)

        present(alert, animated: true)
    }
}
