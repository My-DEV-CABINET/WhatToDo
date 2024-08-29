//
//  RenewalCreateTodoVC.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/29/24.
//

// Rx
import RxCocoa
import RxGesture
import RxSwift

// Apple
import UIKit

final class CreateToDoVC: UIViewController {
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var trashBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!

    @IBOutlet weak var confirmImg: UIImageView!
    @IBOutlet weak var confirmSW: UISwitch!
    @IBOutlet weak var inputTV: UITextView!

    /// Add ViewModel
    var viewModel: CreateTodoViewModel!

    /// Add 후 ToDoVC 이벤트 처리 클로저
    var addSubject: PublishSubject<Bool> = .init()
    /// Edit 후 EditVC 이벤트 처리 클로저
    var editSubject: PublishSubject<(String, Bool)> = .init()

    var disposeBag = DisposeBag()
}

// MARK: - 뷰 생명주기 메서드 모음

extension CreateToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        inputTV.becomeFirstResponder()
        setupUI()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - 뷰 UI 메서드 모음

extension CreateToDoVC {
    private func setupUI() {
        saveBtn.layer.cornerRadius = 10

        inputTV.layer.cornerRadius = 10
        inputTV.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }

    /// 데이터 주입 처리
    private func configure() {
        guard let todo = viewModel.todo else { return }
        guard let title = todo.title else { return }
        guard let isDone = todo.isDone else { return }

        if viewModel.userAction == .edit {
            inputTV.text = title
            confirmSW.isOn = isDone
        }
    }
}

// MARK: - 뷰 Bind 메서드 모음

extension CreateToDoVC {
    private func bind() {
        keyboardBind()

        viewBind()
        textViewBind()
    }

    private func viewBind() {
        view.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe { (owner, _) in
                owner.hideKeyboardWhenTappedAround()
            }
            .disposed(by: disposeBag)

        exitBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        trashBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showAlertMessage(title: "초기화 알림", detail: "작성 중인 모든 내용이 초기화 됩니다. 초기화 할까요?")
                    .withUnretained(self)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (owner, valid) in
                        if valid {
                            owner.resetUI()
                        }
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)

        confirmSW.rx.isOn
            .asDriver()
            .drive(onNext: { [weak self] observer in
                guard let self = self else { return }
                let img = observer ? "flag.circle.fill" : "flag.circle"
                confirmImg.image = UIImage(systemName: img)
            })
            .disposed(by: disposeBag)

        saveBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let text = self.inputTV.text else { return }

                let customQueue = DispatchQueue(label: QueueCollection.save.rawValue, qos: .userInitiated)
                let isDone = self.confirmSW.isOn

                textException(text: text, isDone: isDone, queue: customQueue)
            })
            .disposed(by: disposeBag)
    }

    private func textViewBind() {
        /// TextView 맨 처음 띄어쓰기 방지, 두번째부터는 띄어쓰기 허용
        inputTV.rx.text
            .orEmpty
            .asObservable()
            .scan("") { lastValue, newValue in
                if newValue.count != 0, newValue == " " {
                    let removeSpaceString = newValue.replacingOccurrences(of: " ", with: "")
                    return removeSpaceString.count == newValue.count ? newValue : lastValue
                }
                return newValue
            }
            .bind(to: inputTV.rx.text)
            .disposed(by: disposeBag)

        /// TextView 입력 시작시, TextView 글자색 변경 처리
        inputTV.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] (text: String) in
                guard let self = self else { return }

                if (self.inputTV.text == """
                저장하고 싶은 할일 내용을 입력해주세요.
                """) {
                    self.inputTV.textColor = .systemGray
                }
            })
            .disposed(by: disposeBag)

        /// TextView 입력이 시작되었을 때, Placeholder 처리
        inputTV.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                if (self.inputTV.text == """
                저장하고 싶은 할일 내용을 입력해주세요.
                """) {
                    self.inputTV.text = nil
                    self.inputTV.textColor = .black
                }
            })
            .disposed(by: disposeBag)

        /// TextVeiw 입력이 종료되었을 때, Placeholder 처리
        inputTV.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                if (self.inputTV.text == nil || self.inputTV.text == "") {
                    self.inputTV.text = """
                    저장하고 싶은 할일 내용을 입력해주세요.
                    """
                    self.inputTV.textColor = .systemGray
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 뷰 Alert 메서드 모음

extension CreateToDoVC {
    private func resetUI() {
        confirmSW.isOn = false
        inputTV.text = "저장하고 싶은 할일 내용을 입력해주세요."
        inputTV.resignFirstResponder()
    }

    /// UserAction 분기처리
    private func providerUserAction(userAction: UserActionCollection, queue: DispatchQueue, text: String, isDone: Bool) {
        if userAction == .add {
            /// UserAction 이 Add 일 때,
            queue.async {
                self.viewModel.createTodo(title: text, isDone: isDone) { success in
                    if success {
                        self.addSubject.onNext(true)
                        DispatchQueue.main.async {
                            self.navigationController?.dismiss(animated: true)
                        }
                    } else {
                        // 오류 처리
                        self.showAlertMessage(title: "할일 추가 ERROR", detail: "할일 추가에 실패하였습니다. 다시 시도해주세요.")
                            .withUnretained(self)
                            .observe(on: MainScheduler.instance)
                            .subscribe(onNext: { (owner, valid) in
                            })
                            .disposed(by: self.disposeBag)
                    }
                }
            }
        } else {
            /// UserAction 이 Edit 일 때,
            queue.async {
                self.viewModel.editTodo(title: text, isDone: isDone) { success in
                    if success {
                        self.editSubject.onNext((text, isDone))

                        DispatchQueue.main.async {
                            self.navigationController?.dismiss(animated: true)
                        }
                    } else {
                        // 오류 처리
                        self.showAlertMessage(title: "할일 추가 ERROR", detail: "할일 추가에 실패하였습니다. 다시 시도해주세요.")
                            .withUnretained(self)
                            .observe(on: MainScheduler.instance)
                            .subscribe(onNext: { (owner, valid) in
                            })
                            .disposed(by: self.disposeBag)
                    }
                }
            }
        }
    }
}

// MARK: - 뷰 예외처리 메서드 모음

extension CreateToDoVC {
    /// SaveButton 누를 시, 예외처리 및 성공처리
    private func textException(text: String, isDone: Bool, queue: DispatchQueue) {
        if text.count < 6 {
            textViewUnderSix(title: "할일 추가 ERROR", detail: "할일 내용이 너무 짧습니다. 6글자 이상 입력해주세요.")
                .withUnretained(self)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { (owner, valid) in
                })
                .disposed(by: disposeBag)
        } else if (text == """
        저장하고 싶은 할일 내용을 입력해주세요.
        """ || text.isEmpty) {
            textViewUnderSix(title: "할일 추가 ERROR", detail: "할일 내용이 없습니다. 내용을 입력해주세요.")
                .withUnretained(self)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { (owner, valid) in
                })
                .disposed(by: disposeBag)
        } else {
            providerUserAction(userAction: viewModel.userAction, queue: queue, text: text, isDone: isDone)
        }
    }
}

// MARK: - 키보드 관련 모음

extension CreateToDoVC {
    private func keyboardBind() {
        /// 키보드가 나타난 직후
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .debug("#### Show Keyboard")
            .subscribe(onNext: { (owner, notification) in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    UIView.animate(
                        withDuration: 0.25,
                        animations: {
                            owner.view.bounds.origin.y = keyboardHeight / 1.4
                        }
                    )
                }
            })
            .disposed(by: disposeBag)

        /// 키보드가 사라질 때
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .debug("#### Hide Keyboard")
            .subscribe(onNext: { (owner, notification) in
                UIView.animate(
                    withDuration: 0.25,
                    animations: {
                        owner.view.bounds.origin.y = 0
                    }
                )
            })
            .disposed(by: disposeBag)
    }
}
