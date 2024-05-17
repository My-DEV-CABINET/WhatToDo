//
//  ViewController.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/16/24.
//

import UIKit

final class ToDoView: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain) // List
    private let floattingButton = UIButton(frame: .zero) // Floatting Button

    deinit {
        print("&&&& ToDoView Deinitialized")
    }
}

// MARK: - View Life Cycle

extension ToDoView {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Setting TableView

extension ToDoView {
    /// 설정 모음
    private func setupUI() {
        view.backgroundColor = .systemBackground
        addView()
        configureTableView()
    }

    /// View 등록 일괄 관리
    private func addView() {
        [tableView, floattingButton].forEach { view.addSubview($0) }
    }

    /// TableView 설정
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // 셀 등록
        tableView.register(<#T##nib: UINib?##UINib?#>, forCellReuseIdentifier: <#T##String#>)

        tableView.dataSource = self
        tableView.delegate = self

        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ]

        NSLayoutConstraint.activate([
            constraints,
        ])
    }
}

// MARK: - UITableViewDataSource

extension ToDoView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(frame: .zero)
    }
}

// MARK: - UITableViewDelegate

extension ToDoView: UITableViewDelegate {
    // TODO: - 셀이 선택됬을 때, 작업 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // To Do Task...
    }
}
