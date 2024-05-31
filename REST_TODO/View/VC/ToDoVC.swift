//
//  ToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

import UIKit

final class ToDoVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    deinit {
        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoVC deinitialize")
    }
}

//MARK: - View Setting 관련 메서드 모음

extension ToDoVC {
    private func setupUI() {
        view.backgroundColor = .systemBlue
        bind()
    }

    private func bind() {
        // ViewModel 이벤트 구독
    }
}
