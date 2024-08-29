//
//  RenewalCreateTodoVC.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/29/24.
//

// Rx
import RxCocoa
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

    private var disposeBag: DisposeBag!
}

// MARK: - 뷰 생명주기 메서드 모음

extension CreateToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        inputTV.layer.cornerRadius = 10
        inputTV.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)

        saveBtn.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposeBag = DisposeBag()
        bind()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - 뷰 Bind 메서드 모음

extension CreateToDoVC {
    private func bind() {
        viewBind()
        textViewBind()
    }

    private func viewBind() {
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
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: View 초기화 버튼 클릭함.")
            })
            .disposed(by: disposeBag)

        confirmSW.rx.isOn
            .asDriver()
            .drive(onNext: { [weak self] _ in
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: Switch 변경")
            })
            .disposed(by: disposeBag)

        saveBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let text = self.inputTV.text else { return }

//                let customQueue = DispatchQueue(label: QueueCollection.save.rawValue, qos: .userInitiated)
//                let isDone = self.todoSwitch.isOn
//
//                textException(text: text, isDone: isDone, queue: customQueue)
                self.navigationController?.dismiss(animated: true)
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
