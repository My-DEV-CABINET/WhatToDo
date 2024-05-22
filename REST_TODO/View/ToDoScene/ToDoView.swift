//
//  ViewController.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/16/24.
//

import Combine
import UIKit

protocol ToDoViewDelegate {
    func goToDetailViewWithAdd()
    func goToDetailViewWithEdit(id: Int)
    func dismissView()
}

final class ToDoView: UIViewController {
    var viewModel: ToDoViewModel!

    private let input: PassthroughSubject<ToDoViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let buttonStackView = UIStackView(frame: .zero)
    private let floatingButton = UIButton(frame: .zero)
    private let addButton = UIButton(frame: .zero)
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
        input.send(.requestGETTodos)
    }
}

// MARK: - Setting TableView

extension ToDoView {
    private func setupUI() {
        addView()
        configureTableView()
        configureSearchVC()

        configureStackView()
        configureHideButton()
        configureAddButton()
        configureFloatingButton()
    }

    private func addView() {
        [tableView, buttonStackView].forEach { view.addSubview($0) }

        [hideButton, addButton, floatingButton].forEach { buttonStackView.addArrangedSubview($0) }
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

    private func configureStackView() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        buttonStackView.axis = .vertical
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10

        let constraints = [
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            buttonStackView.widthAnchor.constraint(equalToConstant: 50),
            buttonStackView.heightAnchor.constraint(equalToConstant: 170),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        addButton.setImage(image, for: .normal)

        addButton.tintColor = .white
        addButton.backgroundColor = .systemOrange

        addButton.layer.cornerRadius = 25
        addButton.layer.masksToBounds = true

        addButton.alpha = 0

        let constraints = [
            addButton.widthAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(constraints)

        addButton.addAction(UIAction(handler: { [weak self] _ in
            print("#### \(#line)")
            self?.delegate?.goToDetailViewWithAdd()
            self?.viewWillDisappear(true)
        }), for: .touchUpInside)
    }

    private func configureHideButton() {
        hideButton.translatesAutoresizingMaskIntoConstraints = false

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "eye.slash", withConfiguration: imageConfig)
        hideButton.setImage(image, for: .normal)

        hideButton.tintColor = .white
        hideButton.backgroundColor = .systemPink

        hideButton.layer.cornerRadius = 25
        hideButton.layer.masksToBounds = true

        hideButton.alpha = 0

        let constraints = [
            hideButton.widthAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(constraints)

        hideButton.addAction(UIAction(handler: { [weak self] _ in
            print("#### \(#line)")
        }), for: .touchUpInside)
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
            floatingButton.widthAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(constraints)

        floatingButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            viewModel.toggleIsTapped()
            rotateMorseButton(viewModel.isTapped)

        }), for: .touchUpInside)
    }

    private func configureSearchVC() {
        searchController.searchBar.searchTextField.layer.cornerRadius = 15
        searchController.searchBar.searchTextField.layer.masksToBounds = true

        searchController.searchBar.searchTextField.backgroundColor = .black

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false

        searchController.delegate = self
        searchController.searchBar.delegate = self

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

// MARK: - 버튼 회전 Method

private extension ToDoView {
    func rotateMorseButton(_ isTapped: Bool) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")

        let fromValue = isTapped ? 0 : CGFloat.pi / 4
        let toValue = isTapped ? CGFloat.pi / 4 : 0
        animation.fromValue = fromValue
        animation.toValue = toValue

        animation.duration = 0.3
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        floatingButton.layer.add(animation, forKey: nil)
    }
}

// MARK: - ViewModel Binding

extension ToDoView {
    private func bind() {
        lazy var buttons: [UIButton] = [self.addButton, self.hideButton]
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output.sink { [weak self] event in
            switch event {
            case .showGETTodos(let todos):
                print("#### 현재 showGETTodos 의 ToDo - 1 갯수: \(todos.count)")
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }

            case .showGETSearchToDosAPI(let todos):
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }

            case .scrolling(let todos):
                print("#### 현재 scrolling 의 ToDo - 1 갯수: \(todos.count)")

                self?.viewModel.toggleFetchingMore()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }

            case .goToEdit(let id):
                self?.delegate?.goToDetailViewWithEdit(id: id)

            case .tapFloattingButton(let isTapped):
                if isTapped == true {
                    buttons.enumerated().forEach { [weak self] (index, button) in
                        button.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1)
                        UIView.animate(withDuration: 0.3, delay: 0.1 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: {
                            button.layer.transform = CATransform3DIdentity
                            button.alpha = 1
                        }, completion: nil)
                        self?.view.layoutIfNeeded()
                    }
                } else {
                    for (index, button) in buttons.reversed().enumerated() {
                        UIView.animate(withDuration: 0.3, delay: 0.1 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: {
                            button.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1)
                            button.alpha = 0
                        }, completion: nil)
                        self?.view.layoutIfNeeded()
                    }
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
        let key = viewModel.sortedSectionKeys[indexPath.section]
        let todo = viewModel.groupedTodos[key]?[indexPath.row]

        if let id = todo?.id {
            input.send(.requestGoToEdit(id: id))
        }
    }

    // 셀 우측 스와이프 - 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let key = viewModel.sortedSectionKeys[indexPath.section]
        let todo = viewModel.groupedTodos[key]?[indexPath.row]

        if let id = todo?.id {
            let action = UIContextualAction(style: .destructive, title: "DELETE") { [weak self] (action, view, success) in
                self?.input.send(.requestDELETEToDoAPI(id: id))
            }
            action.image = UIImage(systemName: "trash")
            action.backgroundColor = UIColor.systemRed
            return UISwipeActionsConfiguration(actions: [action])
        }

        return .init()
    }

    // 셀 좌측 스와이프 - 수정
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let key = viewModel.sortedSectionKeys[indexPath.section]
        let todo = viewModel.groupedTodos[key]?[indexPath.row]

        if let id = todo?.id {
            let action = UIContextualAction(style: .destructive, title: "EDIT") { [weak self] (action, view, success) in
                self?.input.send(.requestGoToEdit(id: id))
            }
            action.image = UIImage(systemName: "square.and.pencil")
            action.backgroundColor = UIColor.systemBlue
            return UISwipeActionsConfiguration(actions: [action])
        }

        return .init()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            if !viewModel.fetchingMore {
                beginForwardFetch()
            }
        }
    }

    func beginForwardFetch() {
        viewModel.toggleFetchingMore()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewModel.increasePageCount()
            self.input.send(.requestScrolling)
        }
    }

    func beginPreviousFetch() {
        viewModel.toggleFetchingMore()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewModel.decreasePageCount()
            self.input.send(.requestScrolling)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - UISearchControllerDelegate

extension ToDoView: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        print(#function, "updateQueriesSuggestions")
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        print(#function, "updateQueriesSuggestions")
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        print(#function, "updateQueriesSuggestions")
    }
}

// MARK: - UISearchBarDelegate

extension ToDoView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        input.send(.requestGETSearchToDosAPI(query: searchText))
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
}

// MARK: - ToDoCellDelegate

extension ToDoView: ToDoCellDelegate {
    func didTapCheckBox(todo: ToDoData) {
        var updateToDo = todo
        if let isDone = updateToDo.isDone {
            updateToDo.isDone = !isDone
        }

        let currentOffset = tableView.contentOffset

        input.send(.requestPUTToDoAPI(todo: updateToDo))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.setContentOffset(currentOffset, animated: false)
        }
    }

    func didTapFavoriteBox(id: Int) {
        print("#### Favorite ID: \(id)")
    }
}
