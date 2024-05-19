//
//  ViewController.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/16/24.
//

import Combine
import UIKit

protocol ToDoViewDelegate {
    func goToDetailView()
}

final class ToDoView: UIViewController {
    var viewModel: ToDoViewModel!

    private let input: PassthroughSubject<ToDoViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let floatingButton = UIButton(frame: .zero)
    private let hideButton = UIButton(frame: .zero)

    private var searchController: UISearchController = .init(searchResultsController: nil)

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

        let dto = ToDoResponseDTO(page: 1, filter: .createdAt, orderBy: .desc, perPage: 10)
        input.send(.requestTodos(dto: dto))
    }
}

// MARK: - Setting TableView

extension ToDoView {
    private func setupUI() {
        addView()
        configureTableView()
        configureFloatingButton()
        configureSearchVC()
    }

    private func addView() {
        [tableView, floatingButton].forEach { view.addSubview($0) }
    }

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

    private func configureFloatingButton() {
        floatingButton.translatesAutoresizingMaskIntoConstraints = false

        let floatingImageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let floatingImage = UIImage(systemName: "plus", withConfiguration: floatingImageConfig)
        floatingButton.setImage(floatingImage, for: .normal)

        floatingButton.tintColor = .white
        floatingButton.backgroundColor = .black

        floatingButton.layer.cornerRadius = 25
        floatingButton.layer.masksToBounds = true

        let constraints = [
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            floatingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            floatingButton.widthAnchor.constraint(equalToConstant: 50),
            floatingButton.heightAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(constraints)

        floatingButton.addAction(UIAction(handler: { _ in
            print("#### \(#line)")
        }), for: .touchUpInside)
    }

    private func configureSearchVC() {
        searchController.searchBar.searchTextField.layer.cornerRadius = 15
        searchController.searchBar.searchTextField.layer.masksToBounds = true

        searchController.searchBar.searchTextField.backgroundColor = .black

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false

        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField,
           let clearButton = searchController.searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton
        {
            textfield.backgroundColor = .black
            textfield.attributedPlaceholder = NSAttributedString(
                string: textfield.placeholder ?? "",
                attributes: [.foregroundColor: UIColor.white]
            )
            textfield.textColor = .white
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = .white
            }
            if let rightView = textfield.rightView as? UIImageView {
                rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
                rightView.tintColor = .white
            }
            if let clearImage = clearButton.image(for: .normal) {
                clearButton.isHidden = false
                let tintedClearImage = clearImage.withTintColor(.white, renderingMode: .alwaysOriginal)
                clearButton.setImage(tintedClearImage, for: .normal)
                clearButton.setImage(tintedClearImage, for: .highlighted)
            } else {
                clearButton.isHidden = true
            }
        }

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.clear,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
        ]
        let attributedPlaceholder = NSAttributedString(string: "할 일 검색", attributes: placeholderAttributes)
        searchController.searchBar.searchTextField.attributedPlaceholder = attributedPlaceholder
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sortedSectionKeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = viewModel.sortedSectionKeys[section]
        return viewModel.groupedTodos[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoCell.identifier, for: indexPath) as? ToDoCell else { return UITableViewCell() }
        let key = viewModel.sortedSectionKeys[indexPath.section]
        if let todo = viewModel.groupedTodos[key]?[indexPath.row] {
            cell.delegate = self
            cell.configure(todo: todo)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray5

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.sortedSectionKeys[section]
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .black

        headerView.addSubview(label)

        let constraints = [
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewDelegate

extension ToDoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.goToDetailView()
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
