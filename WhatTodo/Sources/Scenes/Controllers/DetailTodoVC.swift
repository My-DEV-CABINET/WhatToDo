//
//  DetailTodoVC.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/29/24.
//

// Rx
import RxCocoa
import RxSwift

// Apple
import UIKit

final class DetailTodoVC: UIViewController {
    @IBOutlet weak var exitBtn: UIButton! // 나가기 버튼
    @IBOutlet weak var editBtn: UIButton! // 편집 버튼
    @IBOutlet weak var flagImg: UIImageView! // 완료 여부 표시 이미지
    @IBOutlet weak var confirmSW: UISwitch! // 완료 여부 스위치
    @IBOutlet weak var inputTV: UITextView! // Todo 내용 표시
}

// MARK: - 뷰 생명주기 메서드 모음

extension DetailTodoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
