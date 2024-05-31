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

    private var todos: [Int] = []

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
        view.backgroundColor = .systemBlue
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
        let todoCell = UINib.init(nibName: Identifier.todoCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: Identifier.todoCell.rawValue)
    }
    
    private func confirmAddButton() {
        addButton.addAction(UIAction(handler: { [weak self] _ in

            let number = Int.random(in: 0 ... 9)
            self?.todos.append(number)

            DispatchQueue.main.async {
                self?.tableView.reloadData()
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: 현재 Todo의 갯수는 \(self?.todos)")
            }
//            let sb: UIStoryboard = .init(name: "DetailToDo", bundle: nil)
//            let vc = sb.instantiateViewController(identifier: "DetailToDoVC")
//            self?.present(vc, animated: true)

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
        return todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.todoCell.rawValue, for: indexPath) as? ToDoCell else { return UITableViewCell() }
        let item = todos[indexPath.row]
        cell.titleLabel.text = item.description
        return cell
    }
}

// MARK: - TableView Delegate 처리

extension ToDoVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
    }
}
