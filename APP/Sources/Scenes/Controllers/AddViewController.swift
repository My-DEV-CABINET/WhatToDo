//
//  DetailToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

/// Rx
import RxSwift

/// Apple
import UIKit

final class AddViewController: UIViewController {
    /// TextField
    @IBOutlet weak var textView: UITextView!

    /// Button
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    /// Switch
    @IBOutlet weak var todoSwitch: UISwitch!

    /// BarButtonItem
    private var backButton: UIBarButtonItem!

    /// Add ViewModel
    var viewModel: AddViewModel!

    /// Add 후 ToDoVC 이벤트 처리 클로저
    var eventHandler: ((Bool) -> Void)?
    /// Edit 후 EditVC 이벤트 처리 클로저
    var editHandler: ((String, Bool) -> Void)?
}

// MARK: - View Life Cycle 관련 모음

extension AddViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()

        /// 키보드 반응
        setupKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.disposeBag = DisposeBag()

        textView.resignFirstResponder()

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - View UI 설정 관련 모음

extension AddViewController {
    private func setupUI() {
        /// 기본 UI 처리
        confirmTextView()
        confirmCancelButton()
        confirmTodoSwitch()

        /// 네비게이션 UI
        confirmNavigationBar()
        confirmBackButton()

        /// Edit 일 때, 화면 구성
        configure()

        /// 빈 화면 터치시 키보드 내리기
        hideKeyboardWhenTappedAround()
    }

    /// 데이터 주입 처리
    private func configure() {
        guard let todo = viewModel.todo else { return }
        guard let title = todo.title else { return }
        guard let isDone = todo.isDone else { return }

        if viewModel.userAction == .edit {
            textView.text = title
            todoSwitch.isOn = isDone
        }
    }

    private func confirmTextView() {
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.black.cgColor

        /// TextView 패딩
        textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }

    private func confirmCancelButton() {
        if viewModel.userAction == .add {
            cancelButton.isHidden = true
        } else {
            cancelButton.isHidden = false
        }
    }

    private func confirmTodoSwitch() {
        todoSwitch.isOn = false /// 기본값은 false
    }
}

// MARK: - ViewModel Rx Binding 관련 모음

extension AddViewController {
    private func bind() {
        textViewBind()
        saveButtonBind()
        cancelButtonBind()
    }

    /// TextView 관련 Bind 모음
    private func textViewBind() {
        /// TextView 맨 처음 띄어쓰기 방지, 두번째부터는 띄어쓰기 허용
        textView.rx.text
            .orEmpty
            .asObservable()
            .scan("") { lastValue, newValue in
                if newValue.count != 0, newValue == " " {
                    let removeSpaceString = newValue.replacingOccurrences(of: " ", with: "")
                    return removeSpaceString.count == newValue.count ? newValue : lastValue
                }
                return newValue
            }
            .bind(to: textView.rx.text)
            .disposed(by: viewModel.disposeBag)

        /// TextView 입력 시작시, TextView 글자색 변경 처리
        textView.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] (text: String) in
                guard let self = self else { return }

                if (self.textView.text == """
                저장하고 싶은 할일 내용을 입력해주세요.
                """) {
                    self.textView.textColor = .systemGray
                }
            })
            .disposed(by: viewModel.disposeBag)

        /// View -> ViewModel TextView 텍스트 입력 내용 전송
        textView.rx.text
            .orEmpty
            .bind(to: viewModel.textViewInputRelay)
            .disposed(by: viewModel.disposeBag)

        /// TextView 입력이 시작되었을 때, Placeholder 처리
        textView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                if (self.textView.text == """
                저장하고 싶은 할일 내용을 입력해주세요.
                """) {
                    self.textView.text = nil
                    self.textView.textColor = .black
                }
            })
            .disposed(by: viewModel.disposeBag)

        /// TextVeiw 입력이 종료되었을 때, Placeholder 처리
        textView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                if (self.textView.text == nil || self.textView.text == "") {
                    self.textView.text = """
                    저장하고 싶은 할일 내용을 입력해주세요.
                    """
                    self.textView.textColor = .systemGray
                }
            })
            .disposed(by: viewModel.disposeBag)
    }

    /// SaveButton 관련 Bind 모음
    private func saveButtonBind() {
        saveButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let text = self.textView.text else { return }

                let customQueue = DispatchQueue(label: QueueCollection.save.rawValue, qos: .userInitiated)
                let isDone = self.todoSwitch.isOn

                textException(text: text, isDone: isDone, queue: customQueue)

            })
            .disposed(by: viewModel.disposeBag)
    }

    /// CancelButton 버튼 관련 Bind 모음
    private func cancelButtonBind() {
        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.showMessageAlert(title: "취소 확인", message: "취소하시면 이전에 입력하신 내용이 전부 사라집니다.", completion: {
                    self?.navigationController?.dismiss(animated: true)
                }, cancel: {
                    self?.textView.becomeFirstResponder()
                })
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - 장풍 코드 리팩토링 메서드 모음

extension AddViewController {
    /// SaveButton 누를 시, 예외처리 및 성공처리
    private func textException(text: String, isDone: Bool, queue: DispatchQueue) {
        if text.count < 6 {
            showBlankMessage(
                title: "할일 추가 ERROR",
                message: "할일 내용이 너무 짧습니다. 6글자 이상 입력해주세요.",
                completion: {}
            )
        } else if (text == """
        저장하고 싶은 할일 내용을 입력해주세요.
        """ || text == nil) {
            showBlankMessage(
                title: "할일 추가 ERROR",
                message: "할일 내용이 없습니다. 내용을 입력해주세요.",
                completion: {}
            )
        } else {
            providerUserAction(userAction: viewModel.userAction, queue: queue, text: text, isDone: isDone)
        }
    }

    /// UserAction 분기처리
    private func providerUserAction(userAction: UserAction, queue: DispatchQueue, text: String, isDone: Bool) {
        if userAction == .add {
            /// UserAction 이 Add 일 때,
            queue.async {
                self.viewModel.createTodo(title: text, isDone: isDone) { success in
                    if success {
                        self.eventHandler?(true)
                        DispatchQueue.main.async {
                            self.navigationController?.dismiss(animated: true)
                        }
                    } else {
                        // 오류 처리
                        DispatchQueue.main.async {
                            self.showBlankMessage(
                                title: "할일 추가 ERROR",
                                message: "할일 추가에 실패하였습니다. 다시 시도해주세요.",
                                completion: {}
                            )
                        }
                    }
                }
            }
        } else {
            /// UserAction 이 Edit 일 때,
            queue.async {
                self.viewModel.editTodo(title: text, isDone: isDone) { success in
                    if success {
                        self.editHandler?(text, isDone)
                        DispatchQueue.main.async {
                            self.navigationController?.dismiss(animated: true)
                        }
                    } else {
                        // 오류 처리
                        DispatchQueue.main.async {
                            self.showBlankMessage(
                                title: "할일 수정 ERROR",
                                message: "할일 수정에 실패하였습니다. 다시 시도해주세요.",
                                completion: {}
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Navigation Bar 관련 모음

extension AddViewController {
    private func confirmNavigationBar() {
        navigationItem.title = viewModel.userAction == .edit ? "할일 수정" : "할일 추가"
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
}

// MARK: - 예외처리 알림

extension AddViewController {
    /// TextView 입력 6글자 미만시, 알림 - 확인만 있음.
    private func showBlankMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        let confirmAlert = UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        }
        alert.addAction(confirmAlert)
        present(alert, animated: true)
    }

    /// 확인, 취소 존재하는 Alert
    private func showMessageAlert(title: String, message: String, completion: @escaping () -> Void, cancel: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAlert = UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        }

        let cancelAlert = UIAlertAction(title: "취소", style: .destructive) { _ in
            cancel()
        }

        alert.addAction(confirmAlert)
        alert.addAction(cancelAlert)

        present(alert, animated: true)
    }
}

// MARK: - 키보드 관련 모음

extension AddViewController {
    private func setupKeyboard() {
        /// 키보드가 나타난 이후
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        /// 키보드가 사라질 때
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// 키보드가 나타난 직후
    @objc private func keyboardWillShow(_ notification: Notification) {
        /// 키보드
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            UIView.animate(
                withDuration: 0.1,
                animations: {
                    self.view.frame.origin.y = -keyboardHeight / 2
                }
            )
        }
    }

    /// 키보드가 사라질 때
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.view.frame.origin.y = 0
            }
        )
    }
}
