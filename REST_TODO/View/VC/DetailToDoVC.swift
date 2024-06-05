//
//  DetailToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

import RxCocoa
import RxSwift

import UIKit

final class DetailToDoVC: UIViewController {
    /// Label
    @IBOutlet weak var userActionLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!

    /// TextField
    @IBOutlet weak var textField: UITextField!

    /// Button
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    /// Switch
    @IBOutlet weak var isConfirmSwitch: UISwitch!

    /// BarButtonItem
    private var backButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!

    var viewModel: DetailToDoViewModel!
}

// MARK: - View Life Cycle 관련 모음

extension DetailToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        uiBind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure(action: viewModel.userAction)
    }
}

// MARK: - View UI 설정 관련 모음

extension DetailToDoVC {
    private func setupUI() {
        confirmNavigationBar()

//        confirmTextField()
        confirmTaskLabel()

        confirmConfirmButton()
        confirmCancelButton()

        confirmBackButton()
        confirmEditButton()
    }

    func configure(action: UserAction) {
        if action == .add {
            userActionLabel.text = "할일 추가"

            editButton.isHidden = true
            taskLabel.isHidden = true
            textField.isHidden = false
//            textField.layer.opacity = 1
//            taskLabel.layer.opacity = 0
//            warningLabel.layer.opacity = 1

            textField.becomeFirstResponder()
        } else {
            guard let todo = viewModel.todo else { return }
            guard let isDone = todo.isDone else { return }
            userActionLabel.text = "할일 수정"

            taskLabel.text = todo.title
            isConfirmSwitch.isOn = isDone

            taskLabel.isHidden = false
            textField.isHidden = true
            warningLabel.isHidden = true
//            textField.layer.opacity = 0
//            taskLabel.layer.opacity = 1
//            warningLabel.layer.opacity = 0
        }
    }
}

// MARK: - ViewModel Rx Binding 관련 모음

extension DetailToDoVC {
    private func uiBind() {
        // 맨 처음 띄어쓰기 방지, 두번째부터는 띄어쓰기 허용
        textField.rx.text.orEmpty.asObservable()
            .scan("") { lastValue, newValue in
                if newValue.count != 0, newValue == " " {
                    let removeSpaceString = newValue.replacingOccurrences(of: " ", with: "")
                    return removeSpaceString.count == newValue.count ? newValue : lastValue
                }
                return newValue
            }
            .bind(to: textField.rx.text)
            .disposed(by: viewModel.disposeBag)

        // View -> ViewModel 텍스트 입력 내용 전송
        textField.rx.text.orEmpty
            .bind(to: viewModel.textInput)
            .disposed(by: viewModel.disposeBag)

        // 6글자 미만시, WarningLabel 표시
        viewModel.textValid
            .drive(warningLabel.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        // 6글자 미만시, ConfirmButton 비활성화
        viewModel.textValid
            .drive(confirmButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)

        // EditButton 클릭 이벤트 전달
        editButton.rx.tap
            .bind(to: viewModel.editButtonTap)
            .disposed(by: viewModel.disposeBag)

        // CancelButton 클릭 이벤트 전달
        cancelButton.rx.tap
            .bind(to: viewModel.editButtonTap)
            .disposed(by: viewModel.disposeBag)

        // Edit 버튼 클릭시, Edit 버튼 숨김 처리
        viewModel.cancelButtonIsHidden
            .drive(editButton.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        // Cancel 버튼 클릭시, Cancel 버튼 숨김 처리
        viewModel.cancelButtonIsHidden
            .drive { result in
                if result {
                    self.cancelButton.isHidden = false
                } else {
                    self.cancelButton.isHidden = true
                }
            }
            .disposed(by: viewModel.disposeBag)

        // Edit 버튼 클릭시, TextField 반응 활성화/비활성화
        viewModel.cancelButtonIsHidden
            .drive { result in
                if result {
                    self.textField.becomeFirstResponder()

                } else {
                    self.textField.resignFirstResponder()
                }
            }
            .disposed(by: viewModel.disposeBag)

        // Edit, Cancel 버튼 클릭시, TextField, TaskLabel 숨김 활성화/비활성화 처리
        viewModel.cancelButtonIsHidden
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if result {
                        self.taskLabel.isHidden = true
                        self.textField.isHidden = false
                        self.warningLabel.isHidden = false
                    } else {
                        // TextField 초기화
                        self.textField.text = ""

                        self.textField.isHidden = true
                        self.warningLabel.isHidden = true
                        self.taskLabel.isHidden = false
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - Navigation 관련 모음

extension DetailToDoVC {
    private func confirmNavigationBar() {
        navigationItem.title = "할일 추가"
        navigationController?.navigationBar.backgroundColor = .systemGray6
    }
}

// MARK: - Bar Button 관련 모음

extension DetailToDoVC {
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

// MARK: - TextField & Label 관련 모음

extension DetailToDoVC {
//    private func confirmTextField() {
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 0))
//        textField.leftViewMode = .always
//
//        textField.underlined(viewSize: textField.frame.width, color: UIColor.systemGray5)
//    }
    
    private func confirmTaskLabel() {
        taskLabel.adjustsFontSizeToFitWidth = true
    }
}

// MARK: - Confirm / Cancel Button

extension DetailToDoVC {
    private func confirmConfirmButton() {
        confirmButton.addAction(UIAction(handler: { [weak self] _ in
            self?.navigationController?.dismiss(animated: true)
        }), for: .touchUpInside)
    }

    private func confirmCancelButton() {
        cancelButton.isHidden = true
    }
}
