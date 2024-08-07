//
//  Extentsion+ViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 7/2/24.
//

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
}
