//
//  ViewController.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/16/24.
//

import Combine
import UIKit

protocol ToDoViewDelegate {
    func didTapToDoRow()
}

final class ToDoView: UIViewController {
    var viewModel: ToDoViewModel!

    private let input: PassthroughSubject<ToDoViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    private let tableView = UITableView(frame: .zero, style: .plain) // List
    private let floattingButton = UIButton(frame: .zero) // Floatting Button
    private let hideButton = UIButton(frame: .zero) // 완료 숨기기 버튼

    var delegate: ToDoViewDelegate?

    deinit {
        print("&&&& ToDoView Deinitialized")
    }
}

// MARK: - View Life Cycle

extension ToDoView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bind()

        let dto = ToDoResponseDTO(page: 1, filter: Filter(rawValue: Filter.createdAt.rawValue)!, orderBy: Order(rawValue: Order.desc.rawValue)!, perPage: 10)
        input.send(.requestTodos(dto: dto))
    }
}

// MARK: - Setting TableView

extension ToDoView {
    /// 설정 모음
    private func setupUI() {
        addView()
        configureTableView()
        configureFloattingButton()
    }

    /// View 등록 일괄 관리
    private func addView() {
        [tableView, floattingButton].forEach { view.addSubview($0) }
    }

    /// TableView 설정
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // 셀 등록
        tableView.register(ToDoCell.self, forCellReuseIdentifier: ToDoCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self

        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureFloattingButton() {
        floattingButton.translatesAutoresizingMaskIntoConstraints = false

        let floattingImageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let floattingImage = UIImage(systemName: "plus", withConfiguration: floattingImageConfig)
        floattingButton.setImage(floattingImage, for: .normal)

        floattingButton.tintColor = .white
        floattingButton.backgroundColor = .black

        floattingButton.layer.cornerRadius = 25
        floattingButton.layer.masksToBounds = true

        let constraints = [
            floattingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            floattingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            floattingButton.widthAnchor.constraint(equalToConstant: 50),
            floattingButton.heightAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(constraints)

        floattingButton.addAction(UIAction(handler: { _ in
            print("#### \(#line)")
        }), for: .touchUpInside)
    }
}

// MARK: - ViewModel Binding

extension ToDoView {
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output.sink { [weak self] event in
            switch event {
            case .showTodos(let todos):
                print("#### \(todos)")

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        .store(in: &subscriptions)
    }
}

// MARK: - UITableViewDataSource

extension ToDoView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoCell.identifier, for: indexPath) as? ToDoCell else { return UITableViewCell() }
        let todo = viewModel.todos?.data?[indexPath.row]
        cell.delegate = self

        if let todo = todo {
            cell.configure(todo: todo)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ToDoView: UITableViewDelegate {
    // TODO: - 셀이 선택됬을 때, 작업 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTapToDoRow()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - ToDoCellDelegate

extension ToDoView: ToDoCellDelegate {
    func didTapCheckBox(id: Int) {
        print("#### Check ID : \(id)")
    }

    func didTapFavoriteBox(id: Int) {
        print("#### Favorite ID: \(id)")
    }
}
