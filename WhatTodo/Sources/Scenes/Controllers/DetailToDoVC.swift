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
    @IBOutlet weak var trashBtn: UIButton! // 삭제 버튼
    @IBOutlet weak var flagImg: UIImageView! // 완료 여부 표시 이미지
    @IBOutlet weak var confirmSW: UISwitch! // 완료 여부 스위치
    @IBOutlet weak var inputTV: UITextView! // Todo 내용 표시

    var viewModel: DetailTodoViewModel!
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
        bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.disposeBag = DisposeBag()
    }
}

// MARK: - 뷰 UI 메서드 모음

extension DetailToDoVC {
    private func setupUI() {
        confirmTextView()
        confirmSwitch()
        configure()
    }

    private func confirmTextView() {
        inputTV.layer.cornerRadius = 10
        inputTV.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
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
    private func bind() {
        btnBind()
    }

    private func btnBind() {
        exitBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let isUpdate = self.viewModel.isUpdate
                self.dismiss(animated: true)
                self.editSubject.onNext(isUpdate)
            })
            .disposed(by: disposeBag)

        editBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.pushAddVC()
            })
            .disposed(by: disposeBag)

        trashBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showMessageAlert(title: "삭제 알림", message: "삭제하시겠습니까?", completion: {
                    self.navigationController?.dismiss(animated: true)

                    self.deleteSubject.onNext(true)
                })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 화면이동 관련 모음

extension DetailToDoVC {
    /// Add 페이지 화면 이동
    private func pushAddVC() {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.create.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.create.id) as? CreateToDoVC else { return }
        vc.viewModel = CreateTodoViewModel()
        vc.viewModel.todo = viewModel.todo
        vc.viewModel.userAction = .edit

        /// AddVC EventHandler
        vc.editSubject
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (owner, results) in
                let newText = results.0
                let newIsDone = results.1

                owner.inputTV.text = newText
                owner.confirmSW.isOn = newIsDone
                owner.viewModel.isUpdate = true

                /// View Model 의 todo 동기화
                owner.viewModel.todo?.title = newText
                owner.viewModel.todo?.isDone = newIsDone
            })
            .disposed(by: vc.disposeBag)

        let navigationVC = UINavigationController(rootViewController: vc)
        present(navigationVC, animated: true)
    }
}

// MARK: - 예외처리 알림

extension DetailToDoVC {
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
