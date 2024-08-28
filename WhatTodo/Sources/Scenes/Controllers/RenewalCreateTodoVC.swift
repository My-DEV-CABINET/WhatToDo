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

final class RenewalCreateTodoVC: UIViewController {
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var trashBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!

    @IBOutlet weak var confirmImg: UIImageView!
    @IBOutlet weak var confirmSW: UISwitch!
    @IBOutlet weak var inputTV: UITextView!
}

// MARK: - 뷰 생명주기 메서드 모음

extension RenewalCreateTodoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
