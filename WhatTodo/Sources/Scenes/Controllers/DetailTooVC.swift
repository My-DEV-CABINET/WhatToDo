//
//  DetailTodoVC.swift
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

final class DetailToDoVC: UIViewController {
    @IBOutlet weak var exitBtn: UIButton! // 나가기 버튼
    @IBOutlet weak var editBtn: UIButton! // 편집 버튼
    @IBOutlet weak var flagImg: UIImageView! // 완료 여부 표시 이미지
    @IBOutlet weak var confirmSW: UISwitch! // 완료 여부 스위치
    @IBOutlet weak var inputTV: UITextView! // Todo 내용 표시

    var viewModel: UpdateTodoViewModel!
    var disposeBag = DisposeBag()

    /// Edit 이벤트 핸들러
    var editSubject: PublishSubject<Bool> = .init()
    /// Delete 이벤트 핸들러
    var deleteSubject: PublishSubject<Bool> = .init()
}

// MARK: - 뷰 생명주기 메서드 모음

extension DetailToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.disposeBag = DisposeBag()
    }
}

// MARK: - 뷰 UI 메서드 모음

extension DetailToDoVC {
    private func setupUI() {
        confirmSwitch()
        configure()
    }

    /// Todo Switch UI
    private func confirmSwitch() {
        confirmSW.isEnabled = false
    }

    /// 데이터 주입
    private func configure() {
        guard let title = viewModel.todo?.title else { return }
        guard let isDone = viewModel.todo?.isDone else { return }
        let img = isDone ? "flag.circle.fill" : "flag.circle"

        flagImg.image = UIImage(systemName: img)
        confirmSW.isOn = isDone
        inputTV.text = title
    }
}

// MARK: - 뷰 Binding

extension DetailToDoVC {
    private func bind() {}

    private func btnBind() {
        exitBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let isUpdate = self?.viewModel.isUpdate else { return }
                self?.navigationController?.popViewController(animated: true)

                self?.editSubject.onNext(isUpdate)
            })
            .disposed(by: disposeBag)

        editBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                //
            })
            .disposed(by: disposeBag)
    }
}
