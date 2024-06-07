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

    var eventHandler: ((Bool) -> Void)?
    var dismissHandler: ((Bool) -> Void)?
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.disposeBag = DisposeBag()
    }
}

// MARK: - View UI 설정 관련 모음

extension DetailToDoVC {
    private func setupUI() {
        confirmNavigationBar()

//        confirmTextField()
        confirmTaskLabel()

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

            textField.becomeFirstResponder()

            confirmButton.isHidden = false
        } else {
            guard let todo = viewModel.todo else { return }
            guard let isDone = todo.isDone else { return }
            guard let previousTitle = todo.title else { return }

            userActionLabel.text = "할일 수정"
            viewModel.previousText = previousTitle

            taskLabel.text = todo.title
            isConfirmSwitch.isOn = isDone
            isConfirmSwitch.isEnabled = false

            taskLabel.isHidden = false
            textField.isHidden = true
            warningLabel.isHidden = true
            confirmButton.isHidden = true
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

        // ViewModel 로 ConfirmButton Tag 값 전달
        confirmButton.rx.tap
            .map { self.confirmButton.tag }
            .bind(to: viewModel.buttonTapRelay)
            .disposed(by: viewModel.disposeBag)

        // ViewModel 로 CancelButton Tag 값 전달
        cancelButton.rx.tap
            .map { self.cancelButton.tag }
            .bind(to: viewModel.buttonTapRelay)
            .disposed(by: viewModel.disposeBag)

        // View -> ViewModel TextField 텍스트 입력 내용 전송
        textField.rx.text.orEmpty
            .bind(to: viewModel.textInputRelay)
            .disposed(by: viewModel.disposeBag)

        // View -> ViewModel TaskLabel 텍스트 입력 내용 전송
        viewModel.textInputRelay
            .subscribe { [weak self] text in
                guard let self = self else { return }
                taskLabel.text = text
            }
            .disposed(by: viewModel.disposeBag)

        // 6글자 미만시, WarningLabel 표시
        viewModel.textValidDriver
            .drive(warningLabel.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        // 6글자 미만시, ConfirmButton 비활성화
        viewModel.textValidDriver
            .drive(confirmButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)

        // EditButton 클릭 이벤트 전달
        editButton.rx.tap
            .bind(to: viewModel.editTapRelay)
            .disposed(by: viewModel.disposeBag)

        // CancelButton 클릭 이벤트 전달
        cancelButton.rx.tap
            .bind(to: viewModel.editTapRelay)
            .disposed(by: viewModel.disposeBag)

        // ConfirmButton 클릭 이벤트 전달
        confirmButton.rx.tap
            .bind(to: viewModel.editTapRelay)
            .disposed(by: viewModel.disposeBag)

        // Edit 버튼 클릭시, Edit 버튼 숨김 처리
        viewModel.isHiddenValid
            .drive(editButton.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        // Edit, Cancel 버튼 클릭시, TextField, TaskLabel 숨김 활성화/비활성화 처리
        viewModel.isHiddenValid
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }

                if result {
                    // 편집 시작
                    self.textField.text = ""
                    self.textField.becomeFirstResponder()

                    self.isConfirmSwitch.isEnabled = true
                    self.taskLabel.isHidden = true

                    self.cancelButton.isHidden = false
                    self.textField.isHidden = false
                    self.warningLabel.isHidden = false
                    self.confirmButton.isHidden = false

                } else {
                    // 편집 종료
                    self.textField.resignFirstResponder()

                    self.cancelButton.isHidden = true
                    self.textField.isHidden = true
                    self.warningLabel.isHidden = true
                    self.taskLabel.isHidden = false
                    self.confirmButton.isHidden = true
                    self.isConfirmSwitch.isEnabled = false
                }

            })
            .disposed(by: viewModel.disposeBag)

        // ViewModel 의 ButtonTapRelay 버튼 값 입력처리
        viewModel.buttonTapRelay
            .subscribe(onNext: { [weak self] tag in
                guard let self = self else { return }
                if viewModel.userAction == .add {
                    // 추가
                    if tag == 1 {
                        guard let text = self.textField.text else { return }
                        let isDone = self.isConfirmSwitch.isOn
                        viewModel.previousText = text
                        viewModel.createTodo(title: text, isDone: isDone) { success in
                            if success {
                                self.eventHandler?(true)
                                self.navigationController?.dismiss(animated: true)
                            } else {
                                // 오류 처리
                                print("#### 할 일 추가 실패")
                            }
                        }
                    }
                } else {
                    // 편집
                    if tag == 1 {
                        // Confirm Button
                        guard let text = self.textField.text else { return }
                        let isDone = self.isConfirmSwitch.isOn

                        viewModel.editTodo(title: text, isDone: isDone) { success in
                            if success {
                                self.viewModel.previousText = text
                                self.eventHandler?(true)
                            } else {
                                // 오류 처리
                                print("#### 할 일 업데이트 실패")
                            }
                        }

                    } else {
                        // Cancel Button
                        self.textField.text = viewModel.previousText
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - Navigation 관련 모음

extension DetailToDoVC {
    private func confirmNavigationBar() {
        navigationItem.title = viewModel.todo?.id?.description
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
    private func confirmCancelButton() {
        cancelButton.isHidden = true
    }
}
