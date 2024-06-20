//
//  ToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

/// Rx
import RxDataSources
import RxSwift

/// Apple
import UIKit
import UserNotifications

// MARK: - RxDataSource Section Model

struct SectionOfCustomData {
    var header: String
    var items: [ToDoData]

    init(header: String, items: [ToDoData]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = ToDoData

    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: - ToDoViewController

final class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var hiddenButton: UIBarButtonItem!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    private var viewModel = ListViewModel()
    private var searchVC: UISearchController!
    private var refreshControl: UIRefreshControl!

    typealias ToDoSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>

    lazy var dataSource: ToDoSectionDataSource = {
        let db = ToDoSectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.todoCell.rawValue, for: indexPath) as? ToDoCell else { return UITableViewCell() }

                guard let id = item.id else { return UITableViewCell() }
                cell.data = item

                /// isDone 스위치 이벤트
                cell.checkHandler = { [weak self] data in
                    guard let title = data.title else { return }
                    guard let isDone = data.isDone else { return }
                    guard let id = data.id else { return }

                    self?.viewModel.editTodo(title: title, isDone: isDone, id: id)
                }

                /// 북마크 스위치 이벤트
                cell.favoriteHandler = { [weak self] id in
                    guard let exist = self?.viewModel.dbManager.fetchFavoriteByID(id: id) else { return }

                    if exist {
                        _ = self?.viewModel.dbManager.deleteFavorite(id: id)

                    } else {
                        _ = self?.viewModel.dbManager.insertFavorite(id: id)
                    }

                    self?.tableView.reloadData()
                }

                cell.configure(data: item, isExistFavorite: self.viewModel.dbManager.fetchFavoriteByID(id: id))
                return cell
            })

        /// 헤더뷰 표시
//        db.titleForHeaderInSection = { dataSource, index in
//            return dataSource.sectionModels[index].header
//        }

        db.canEditRowAtIndexPath = { dataSource, indexPath in
            return true
        }

        db.canMoveRowAtIndexPath = { dataSource, indexPath in
            return true
        }

        return db
    }()

    deinit {
        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoVC deinitialize")
    }
}

// MARK: - View Life Cycle 관련 메서드 모음

extension ListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.requestGETTodos(completion: {})
    }
}

// MARK: - View Setting 관련 메서드 모음

extension ListViewController {
    private func setupUI() {
        view.backgroundColor = .white
        registerCell()
        confirmTableView()
        confirmRefreshControl()
        confirmActivityView()
        confirmSearchVC()
        confirmAddButton()

        /// 화면 터치시, 키보드 내리기
        hideKeyboardWhenTappedAround()

        /// Binding
        bind()
    }

    /// Xib 셀 등록
    private func registerCell() {
        /// TableView Cell
        let todoCell = UINib(nibName: Identifier.todoCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: Identifier.todoCell.rawValue)

        /// TableView Header Cell
        let haderCell = UINib(nibName: Identifier.headerView.rawValue, bundle: nil)
        tableView.register(haderCell, forHeaderFooterViewReuseIdentifier: Identifier.headerView.rawValue)
    }

    /// Alert 페이지
    private func showBlankMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAlert = UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        }
        alert.addAction(confirmAlert)
        present(alert, animated: true)
    }

    /// Floatting 버튼 구성 및 화면 이동 로직
    private func confirmAddButton() {
        addButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            pushAddVC()
        }), for: .touchUpInside)
    }

    /// ActivityIndicatorView 설정
    private func confirmActivityView() {
        indicatorView.hidesWhenStopped = true
    }

    /// Add 페이지 화면 이동
    private func pushAddVC() {
        let sb: UIStoryboard = .init(name: "ADD", bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: "AddViewController") as? AddViewController else { return }
        vc.viewModel = AddViewModel()

        vc.eventHandler = { [weak self] _ in
            self?.viewModel.resetPage()

            DispatchQueue.main.async {
                self?.tableView.setContentOffset(.zero, animated: true)
            }

            let customQueue = DispatchQueue(label: "eventHandler-ADD")
            customQueue.async {
                self?.viewModel.requestGETTodos(completion: {})
            }
        }

        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.isModalInPresentation = true /// 사용자가 실수로 모달뷰를 닫지 못하도록 처리
        present(navigationVC, animated: true)
    }

    private func confirmTableView() {
        tableView.bounces = true
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .singleLine
        tableView.indicatorStyle = .default
    }

    private func confirmRefreshControl() {
        refreshControl = UIRefreshControl()

        tableView.refreshControl = refreshControl
    }

    private func confirmSearchVC() {
        searchVC = UISearchController(searchResultsController: nil)
        searchVC.obscuresBackgroundDuringPresentation = false
        searchVC.hidesNavigationBarDuringPresentation = false
        searchVC.automaticallyShowsCancelButton = true

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchVC
    }
}

// MARK: - ViewModel Rx Binding 관련 처리 메서드 모음

extension ListViewController {
    private func bind() {
        rxDatasourceBind()
        tableViewBind()
        searchBind()
        hiddenBind()
    }

    private func rxDatasourceBind() {
        /// RxDataSource에 데이터 주입
        viewModel.todoBehaviorSubject
            .map { todos in
                // CreatedAt 기준으로 Dictionary 생성
                let groupedDictionary = Dictionary(grouping: todos) { todo in
                    return todo.updatedAt?.dateFormatterForDate() ?? ""
                }

                // 날짜 정렬
                let sortedKeys = groupedDictionary.keys.sorted(by: >)

                // SectionOfCustomData 생성
                return sortedKeys.map { key in
                    SectionOfCustomData(header: key, items: groupedDictionary[key] ?? [])
                }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
    }

    private func tableViewBind() {
        /// TableView Delegate
        tableView.rx.setDelegate(self)
            .disposed(by: viewModel.disposeBag)

        /// TableView Cell 선택
        tableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .bind { [weak self] indexPath in
                guard let self = self else { return }

                let currentSection = self.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]

                guard let id = currentItem.id else { return }

                SeenManager.shared.insertSeenList(id: id)

                let sb: UIStoryboard = .init(name: "EDIT", bundle: nil)
                guard let vc = sb.instantiateViewController(identifier: "EditViewController") as? EditViewController else { return }
                vc.viewModel = EditViewModel()
                vc.viewModel.todo = currentItem

                let navigationVC = UINavigationController(rootViewController: vc)
                navigationVC.isModalInPresentation = true /// 사용자가 실수로 모달뷰를 닫지 못하도록 처리
                present(navigationVC, animated: true)

                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)

                /// EditVC 의 EventHandler 처리
                vc.eventHandler = { [weak self] valid in
                    if valid {
                        self?.viewModel.resetPage()
                        self?.tableView.setContentOffset(.zero, animated: true)

                        let customQueue = DispatchQueue(label: "eventHandler-ADD")
                        customQueue.async {
                            self?.viewModel.requestGETTodos(completion: {})
                        }
                    }
                }

                /// EditVC 의 DeleteHandler 처리
                vc.deleteHandler = { [weak self] valid in
                    guard let self = self else { return }

                    if valid {
                        self.viewModel.removeTodo(data: currentItem, completion: {
                            _ = self.viewModel.dbManager.deleteFavorite(id: id)

                            guard let details = currentItem.title else { return }
                            UNUserNotificationCenter.current().addNotificationRequest(title: "할일 삭제됨", details: details)
                        })
                    }
                }
            }
            .disposed(by: viewModel.disposeBag)

        /// TableView RefreshControl 이벤트 처리
        refreshControl.rx.controlEvent(.valueChanged)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.viewModel.resetPage()
                    self?.indicatorView.isHidden = true
                    let customQueue = DispatchQueue(label: "refresh")

                    if self?.searchVC.isActive == true {
                        guard let text = self?.searchVC.searchBar.text else { return }

                        customQueue.async {
                            self?.viewModel.searchTodo(query: text, completion: { [weak self] todos in

                                DispatchQueue.main.async {
                                    if todos.count == 0 {
                                        self?.showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                                            self?.searchVC.searchBar.text = text
                                            self?.searchVC.searchBar.becomeFirstResponder()
                                            self?.refreshControl.endRefreshing()
                                        })
                                    } else {
                                        self?.refreshControl.endRefreshing()
                                    }
                                }
                            })
                            self?.viewModel.paginationRelay.accept(false)
                        }
                    } else {
                        customQueue.async {
                            self?.viewModel.requestGETTodos(completion: {
                                DispatchQueue.main.async {
                                    self?.refreshControl.endRefreshing()
                                }
                            })
                        }
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)

        /// 페이징 처리
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                guard !viewModel.paginationRelay.value else { return } /// True 이면, API 호출하지 않고, 조기 종료

                let sections = dataSource.sectionModels
                let totalItemsCount = sections.flatMap { $0.items }.count
                let currentIndex = sections.prefix(indexPath.section).flatMap { $0.items }.count + indexPath.row

                let customQueue = DispatchQueue(label: "validPagination")

                if currentIndex == totalItemsCount - 2, !viewModel.paginationRelay.value {
                    self.indicatorView.startAnimating()
                    self.viewModel.increasePage()
                    if self.searchVC.isActive == true, self.searchVC.searchBar.text?.isEmpty == false {
                        /// 서치바 동작 상태일 때
                        guard let text = self.searchVC.searchBar.text else { return }

                        customQueue.async {
                            self.viewModel.requestMoreQueryTodos(query: text) { valid in

                                DispatchQueue.main.async {
                                    if !valid {
                                        self.viewModel.paginationRelay.accept(true)
                                    }

                                    self.indicatorView.stopAnimating()
                                }
                            }
                        }

                    } else if self.searchVC.isActive == true, self.searchVC.searchBar.text == "" {
                        customQueue.async {
                            self.viewModel.requestMoreTodos { valid in

                                DispatchQueue.main.async {
                                    if !valid {
                                        self.viewModel.paginationRelay.accept(true)
                                    }

                                    self.indicatorView.stopAnimating()
                                }
                            }
                        }
                    } else {
                        /// 서치바 동작 상태 아닐 때
                        customQueue.async {
                            self.viewModel.requestMoreTodos { valid in

                                DispatchQueue.main.async {
                                    if !valid {
                                        self.viewModel.paginationRelay.accept(true)
                                    }

                                    self.indicatorView.stopAnimating()
                                }
                            }
                        }
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)
    }

    private func searchBind() {
        /// SearchBar 입력 이벤트 처리
        searchVC.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.resetPage()
                self?.viewModel.paginationRelay.accept(false)
                self?.indicatorView.isHidden = true

                let customQueue = DispatchQueue(label: "searchBar")

                if self?.searchVC.isActive == true, text.isEmpty != true {
                    customQueue.async {
                        self?.viewModel.searchTodo(query: text, completion: { [weak self] todos in

                            DispatchQueue.main.async {
                                if todos.count == 0, self?.searchVC.searchBar.isFirstResponder == true {
                                    self?.showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                                        self?.indicatorView.stopAnimating()
                                        self?.searchVC.searchBar.text = text
                                        self?.searchVC.searchBar.becomeFirstResponder()

                                        self?.tableView.setContentOffset(.zero, animated: true)
                                    })
                                }
                            }
                        })
                    }

                } else if self?.searchVC.isActive == true, text.isEmpty == true {
                    customQueue.async {
                        self?.viewModel.requestGETTodos(completion: {
                            DispatchQueue.main.async {
                                self?.tableView.setContentOffset(.zero, animated: true)
                            }
                        })
                    }
                }

            })
            .disposed(by: viewModel.disposeBag)

        /// SearchBar 취소 이벤트 처리
        searchVC.searchBar.rx.cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in

                self?.searchVC.searchBar.text = ""
                self?.viewModel.resetPage()
                self?.viewModel.paginationRelay.accept(false)

                let customQueue = DispatchQueue(label: "searchBarCancel")
                customQueue.async {
                    self?.viewModel.requestGETTodos(completion: {})
                }

                self?.searchVC.searchBar.resignFirstResponder()
                self?.tableView.setContentOffset(.zero, animated: true)
            })
            .disposed(by: viewModel.disposeBag)
    }

    private func hiddenBind() {
        /// 완료 보이기 이벤트 전달
        hiddenButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let isHidden = self?.viewModel.hiddenRelay.value else { return }

                self?.tableView.setContentOffset(.zero, animated: true)

                self?.viewModel.hiddenRelay.accept(!isHidden)
            }
            .disposed(by: viewModel.disposeBag)

        /// 완료 보이기 여부에 따라서 버튼명 변경 및 Todos 데이터 호출
        viewModel.validHidden
            .drive(onNext: { [weak self] title in
                self?.hiddenButton.title = title
                self?.viewModel.resetPage()

                let customQueue = DispatchQueue(label: "validHidden")

                if self?.searchVC.isActive == true {
                    guard let text = self?.searchVC.searchBar.text else { return }
                    /// 검색창 활성화
                    if text == "" {
                        customQueue.async {
                            self?.viewModel.requestGETTodos(completion: {})
                        }
                    } else {
                        customQueue.async {
                            self?.viewModel.searchTodo(query: text, completion: { [weak self] todos in
                                if todos.count == 0 {
                                    DispatchQueue.main.async {
                                        self?.showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                                            self?.indicatorView.stopAnimating()
                                            self?.searchVC.searchBar.text = text
                                            self?.searchVC.searchBar.becomeFirstResponder()

                                            self?.tableView.setContentOffset(.zero, animated: true)

                                        })
                                    }
                                }
                            })
                        }
                    }
                } else {
                    /// 검색창 비활성화
                    customQueue.async {
                        self?.viewModel.requestGETTodos(completion: {})
                    }
                }
                self?.viewModel.paginationRelay.accept(false)

            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - UITableViewDelegate 처리

extension ListViewController: UITableViewDelegate {
    /// 셀 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, perform in
            let currentSection = self.dataSource.sectionModels[indexPath.section]
            let currentItem = currentSection.items[indexPath.row]
            guard let id = currentItem.id else { return }

            self.viewModel.removeTodo(data: currentItem, completion: {
                _ = self.viewModel.dbManager.deleteFavorite(id: id)

                guard let details = currentItem.title else { return }
                UNUserNotificationCenter.current().addNotificationRequest(title: "할일 삭제됨", details: details)
            })
        }

        let configuration = UISwipeActionsConfiguration(actions: [
            deleteAction
        ])

        return configuration
    }

    /// 셀 높이 설정
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    /// 헤더 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Identifier.headerView.rawValue) as? HeaderView else { return UIView() }
        header.dateLabel.text = dataSource.sectionModels[section].header
        return header
    }

    /// 헤더 높이 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
