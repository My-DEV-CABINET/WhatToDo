//
//  ToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

import UIKit

enum Identifier: String {
    case todoCell = "ToDoCell"
}

final class ToDoVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    private var viewModel = ToDoViewModel()

    deinit {
        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoVC deinitialize")
    }
}

// MARK: - View Life Cycle 관련 메서드 모음

extension ToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - View Setting 관련 메서드 모음

extension ToDoVC {
    private func setupUI() {
        view.backgroundColor = .systemGray
        registerCell()
        confirmTableView()
        confirmAddButton()
//        bind()
    }

    private func confirmTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func registerCell() {
        let todoCell = UINib(nibName: Identifier.todoCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: Identifier.todoCell.rawValue)
    }

    private func confirmAddButton() {
        addButton.addAction(UIAction(handler: { [weak self] _ in

            let sb: UIStoryboard = .init(name: "DetailToDo", bundle: nil)
            let vc = sb.instantiateViewController(identifier: "DetailToDoVC")
            let navigationVC = UINavigationController(rootViewController: vc)
            self?.present(navigationVC, animated: true)

        }), for: .touchUpInside)
    }
}

// MARK: - ViewModel Binding 관련 처리 메서드 모음

extension ToDoVC {
    private func bind() {
        // ViewModel 이벤트 구독
    }
}

// MARK: - TableView DataSource 처리

extension ToDoVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.todoCell.rawValue, for: indexPath) as? ToDoCell else { return UITableViewCell() }

        return cell
    }
}

// MARK: - TableView Delegate 처리

extension ToDoVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
    }
}
