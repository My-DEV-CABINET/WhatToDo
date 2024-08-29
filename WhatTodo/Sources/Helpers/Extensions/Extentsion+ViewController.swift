//
//  Extentsion+ViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 7/2/24.
//

// Rx
import RxCocoa
import RxSwift

// Apple
import UIKit

extension UIViewController {
    func pushAlertVC(title: String, detail: String, image: String) {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.alert.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.alert.id) as? AlertVC else { return }
        vc.configure(title: title, detail: detail, image: image)

        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalTransitionStyle = .crossDissolve
        navigationVC.isModalInPresentation = true /// 사용자가 실수로 모달뷰를 닫지 못하도록 처리
        present(navigationVC, animated: true)
    }

    func showAlertMessage(title: String, detail: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let alertController = UIAlertController(title: title, message: detail, preferredStyle: .alert)

            let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
                observer.onNext(true)
                observer.onCompleted()
            }

            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                observer.onNext(false)
                observer.onCompleted()
            }

            [cancelAction, confirmAction].forEach { alertController.addAction($0) }
            self.present(alertController, animated: true, completion: nil)

            return Disposables.create()
        }
    }

    /// TextView 입력 6글자 미만시, 알림 - 확인만 있음.
    func textViewUnderSix(title: String, detail: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let alert = UIAlertController(title: title, message: detail, preferredStyle: .actionSheet)

            let confirmAlert = UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(true)
            }
            alert.addAction(confirmAlert)
            present(alert, animated: true)

            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
}
