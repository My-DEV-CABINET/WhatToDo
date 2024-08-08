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

// MARK: - ReadToDoVC

final class ReadToDoVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var historyButton: UIBarButtonItem!

    private var viewModel = ReadTodoViewModel()
    private var searchController: UISearchController!
    private var refreshControl: UIRefreshControl!

    typealias ToDoSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>

    private var dataSource: ToDoSectionDataSource!

    deinit {
        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoVC deinitialize")
    }
}

// MARK: - View Life Cycle 관련 메서드 모음

extension ReadToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.requestGETTodos(completion: {
            self.tableView.reloadData()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
    }
}

// MARK: - View Setting 관련 메서드 모음

extension ReadToDoVC {
    private func setupUI() {
        registerCell()
        confirmDatasource()
        confirmTableView()
        confirmRefreshControl()
        //        confirmSearchVC()

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

    private func confirmDatasource() {
        dataSource = ToDoSectionDataSource(
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

                let inquires = self.viewModel.dbManager.inquireHistories
                let isInquire = inquires.contains(where: { $0.todoID == id })
                cell.configure(data: item, isInquire: isInquire)

                cell.backgroundColor = .clear
                return cell
            })

        dataSource?.canEditRowAtIndexPath = { dataSource, indexPath in
            return true
        }

        dataSource?.canMoveRowAtIndexPath = { dataSource, indexPath in
            return true
        }
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

//    private func confirmSearchVC() {
//        searchVC = UISearchController(searchResultsController: nil)
//        searchVC.obscuresBackgroundDuringPresentation = false
//        searchVC.hidesNavigationBarDuringPresentation = false
//        searchVC.automaticallyShowsCancelButton = true
//
//        navigationItem.hidesSearchBarWhenScrolling = false
//        navigationItem.searchController = searchVC
//    }

    /// Alert 메시지 표시
    private func showBlankMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAlert = UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        }
        alert.addAction(confirmAlert)
        present(alert, animated: true)
    }
}

// MARK: - 화면 이동 메서드 모음

extension ReadToDoVC {
    /// Filter 페이지 이동
    private func pushFilterVC() {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.filter.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.filter.id) as? FilterToDoVC else { return }

        vc.eventSubject
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { (owner, _) in
                owner.viewModel.paginationRelay.accept(false)
                owner.viewModel.resetPage()
                owner.viewModel.requestGETTodos(completion: {})
            }
            .disposed(by: vc.disposeBag)

        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .formSheet
        navigationVC.isModalInPresentation = true /// 사용자가 실수로 모달뷰를 닫지 못하도록 처리
        present(navigationVC, animated: true)
    }

    /// Add 페이지 화면 이동
    private func pushAddVC() {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.create.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.create.id) as? CreateToDoVC else { return }
        vc.viewModel = CreateTodoViewModel()

        vc.addSubject
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (owner, value) in
                owner.viewModel.resetPage()

                DispatchQueue.main.async {
                    owner.tableView.setContentOffset(.zero, animated: true)
                }

                let customQueue = DispatchQueue(label: QueueCollection.add.rawValue)
                customQueue.async {
                    owner.viewModel.requestGETTodos(completion: {})
                }
            })
            .disposed(by: vc.disposeBag)

        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .pageSheet
        navigationVC.isModalInPresentation = true /// 사용자가 실수로 모달뷰를 닫지 못하도록 처리
        present(navigationVC, animated: true)
    }

    /// 검색 페이지 이동
    private func pushSearchVC() {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.search.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.search.id) as? SearchToDoVC else { return }

        navigationController?.pushViewController(vc, animated: true)
    }

    /// 알림 내역 페이지 이동
    private func pushHistoryVC() {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.history.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.history.id) as? HistoryToDoVC else { return }

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - ViewModel Rx Binding 관련 처리 메서드 모음

extension ReadToDoVC {
    private func bind() {
        viewBind()
        rxDatasourceBind()
        tableViewBind()
        //        searchBind()
    }

    private func viewBind() {
        /// Add 버튼 클릭시, AddVC 로 화면이동
        addButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.pushAddVC()
            })
            .disposed(by: viewModel.disposeBag)

        filterButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.pushFilterVC()
            })
            .disposed(by: viewModel.disposeBag)

        searchButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.pushSearchVC()
            })
            .disposed(by: viewModel.disposeBag)

        historyButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.pushHistoryVC()
            })
            .disposed(by: viewModel.disposeBag)
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
                let sortedKeys = groupedDictionary.keys.sorted(by: { self.viewModel.orderBy == Order.desc.rawValue ? $0 > $1 : $0 < $1 })

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

                let customQueue = DispatchQueue(label: QueueCollection.selected.rawValue)
                let currentSection = self.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]

                guard let id = currentItem.id else { return }
                self.viewModel.dbManager.createInquireHistory(id: id)

                let sb: UIStoryboard = .init(name: StoryBoardCollection.update.id, bundle: nil)
                guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.update.id) as? UpdateToDoVC else { return }
                vc.viewModel = UpdateTodoViewModel()
                vc.viewModel.todo = currentItem
                navigationController?.pushViewController(vc, animated: true)

                /// EditVC 의 EventHandler 처리
                vc.eventHandler = { [weak self] valid in
                    guard let self = self else { return }

                    if valid {
                        self.viewModel.resetPage()
                        self.tableView.setContentOffset(.zero, animated: true)

                        customQueue.async {
                            self.viewModel.requestGETTodos(completion: {})
                        }
                    }
                }

                /// EditVC 의 DeleteHandler 처리
                vc.deleteHandler = { [weak self] valid in
                    guard let self = self else { return }

                    if valid {
                        customQueue.async {
                            self.viewModel.removeTodo(data: currentItem, completion: {
                                guard let details = currentItem.title else { return }
                                UNUserNotificationCenter.current().addNotificationRequest(title: "할일 삭제됨", details: details)
                            })
                        }
                    }
                }

                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            .disposed(by: viewModel.disposeBag)

        /// 페이징 처리
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                guard !viewModel.paginationRelay.value else { return } /// True 이면, API 호출하지 않고, 조기 종료

                let sections = dataSource.sectionModels
                let totalItemsCount = sections.flatMap { $0.items }.count
                let currentIndex = sections.prefix(indexPath.section).flatMap { $0.items }.count + indexPath.row

                let customQueue = DispatchQueue(label: QueueCollection.paging.rawValue)

                if currentIndex == totalItemsCount - 2 {
                    viewModel.increasePage()
                    customQueue.async {
                        self.viewModel.requestMoreTodos { valid in
                            DispatchQueue.main.async {
                                if !valid {
                                    self.pushAlertVC(title: "알림⚠️", detail: "마지막 페이지에 도달했습니다.", image: "book.pages")
                                    self.viewModel.paginationRelay.accept(true)
                                }
                            }
                        }
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)

        /// TableView RefreshControl 이벤트 처리
        refreshControl.rx.controlEvent(.valueChanged)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.viewModel.paginationRelay.accept(false)
                    let customQueue = DispatchQueue(label: QueueCollection.refresh.rawValue)

                    self.viewModel.resetPage()

                    customQueue.async {
                        self.viewModel.requestGETTodos(completion: {
                            DispatchQueue.main.async {
                                self.refreshControl.endRefreshing()
                            }
                        })
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)
    }

//    private func searchBind() {
//        /// SearchBar 입력 이벤트 처리
//        searchVC.searchBar.rx.text
//            .orEmpty
//            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] text in
//                guard let self = self else { return }
//
//                self.viewModel.resetPage()
//                self.viewModel.paginationRelay.accept(false)
//
//                let customQueue = DispatchQueue(label: QueueCollection.search.rawValue)
//
//                if self.searchVC.isActive == true {
//                    self.searchBarIsEmpty(text: text, isEmpty: text.isEmpty, queue: customQueue)
//                }
//            })
//            .disposed(by: viewModel.disposeBag)
//
//        /// SearchBar 취소 이벤트 처리
//        searchVC.searchBar.rx.cancelButtonClicked
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//
//                let customQueue = DispatchQueue(label: QueueCollection.searchCancel.rawValue)
//                self.searchVC.searchBar.text = ""
//                self.viewModel.resetPage()
//                self.viewModel.paginationRelay.accept(false)
//
//                customQueue.async {
//                    self.viewModel.requestGETTodos(completion: {})
//                }
//
//                self.searchVC.searchBar.resignFirstResponder()
//                self.tableView.setContentOffset(.zero, animated: true)
//            })
//            .disposed(by: viewModel.disposeBag)
//    }
}

// MARK: - 장풍 코드 리팩토링 메서드 모음

extension ReadToDoVC {
    /// 검색 결과 아무것도 없을 시, 오류 메시지 VC 표시
    private func returnNonTodosAtSearching(todos: [ToDoData], searchBarText: String) {
        if todos.count == 0, searchController.searchBar.isFirstResponder == true {
            showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                self.searchController.searchBar.text = searchBarText
                self.searchController.searchBar.becomeFirstResponder()
                self.tableView.setContentOffset(.zero, animated: true)
            })
        } else {
            searchController.searchBar.resignFirstResponder()
        }

        return
    }

    /// Refresh Control 동작시, 오류 메시지 VC 표시
    private func returnNonTodosAtRefreshControl(todos: [ToDoData], searchBarText: String) {
        if todos.count == 0 {
            showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                self.searchController.searchBar.text = searchBarText
                self.searchController.searchBar.becomeFirstResponder()
                self.refreshControl.endRefreshing()
                return
            })
        } else {
            refreshControl.endRefreshing()
        }
    }

    /// 하단 Indicator View 멈추기
    private func stopBottomIndicatorView(spinner: UIActivityIndicatorView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 데이터 추가 로드 후
            spinner.stopAnimating()
            self.tableView.tableFooterView = nil
        }
    }

    /// 마지막 페이지 도달시, AlertVC 표시
    private func arriveAtLastPage(valid: Bool) {
        if !valid {
            DispatchQueue.main.async {
                self.pushAlertVC(title: "알림⚠️", detail: "마지막 페이지에 도달했습니다.", image: "book.pages")
                self.viewModel.paginationRelay.accept(true)
            }
        }
    }

    /// SearchBar가 빈칸일 때, 분기 처리
    private func searchBarIsNone(text: String, queue: DispatchQueue) {
        if text != "" {
            /// 검색 중 + 빈칸이 아닐 때
            queue.async {
                self.viewModel.searchTodo(query: text, completion: { [weak self] todos in

                    DispatchQueue.main.async {
                        self?.returnNonTodosAtRefreshControl(todos: todos, searchBarText: text)
                    }
                })
                self.viewModel.paginationRelay.accept(false)
            }
        } else {
            /// 검색 중 + 빈칸일 때
            refreshControl.endRefreshing()
        }
    }

    /// SearchBar가 공백일 때, 분기 처리
    private func searchBarIsEmpty(text: String, isEmpty: Bool, queue: DispatchQueue) {
        if isEmpty == false {
            queue.async {
                self.viewModel.searchTodo(query: text, completion: { [weak self] todos in
                    guard let self = self else { return }

                    DispatchQueue.main.async {
                        self.returnNonTodosAtSearching(todos: todos, searchBarText: text)
                    }
                })
            }
        } else {
            queue.async {
                self.viewModel.requestGETTodos(completion: {
                    DispatchQueue.main.async {
                        self.tableView.setContentOffset(.zero, animated: true)
                    }
                })
            }
        }
    }

    /// 페이징 처리 요청시, SearchBar가 빈칸일 때, 분기 처리
    private func searchBarIsNoneWhenPaging(text: String, queue: DispatchQueue) {
        if text != "" {
            queue.asyncAfter(deadline: .now() + 0.5) {
                self.viewModel.requestMoreQueryTodos(query: text) { valid in
                    self.arriveAtLastPage(valid: valid)
                }
            }
        } else {
            queue.asyncAfter(deadline: .now() + 0.5) {
                self.viewModel.requestMoreTodos { valid in
                    self.arriveAtLastPage(valid: valid)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate 처리

extension ReadToDoVC: UITableViewDelegate {
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        let currentOffset = scrollView.contentOffset.y
//        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//
//        if maximumOffset < currentOffset, currentOffset > 0 {
//            loadMoreData()
//        }
//    }
//
//    /// 페이징 처리
//    private func loadMoreData() {
//        let spinner = UIActivityIndicatorView(style: .large)
//        spinner.startAnimating()
//        spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
//        tableView.tableFooterView = spinner
//
//        /// True 이면, API 호출하지 않고, 조기 종료
//        guard !viewModel.paginationRelay.value else {
//            stopBottomIndicatorView(spinner: spinner)
//            return
//        }
//
//        guard let text = searchVC.searchBar.text else { return }
//        let customQueue = DispatchQueue(label: QueueCollection.paging.rawValue)
//
//        if !viewModel.paginationRelay.value {
//            viewModel.increasePage()
//
//            if searchVC.isActive == true {
//                /// 서치바 동작 상태일 때
//                searchBarIsNoneWhenPaging(text: text, queue: customQueue)
//
//            } else {
//                /// 서치바 동작 상태 아닐 때
//                customQueue.asyncAfter(deadline: .now() + 0.5) {
//                    self.viewModel.requestMoreTodos { valid in
//                        self.arriveAtLastPage(valid: valid)
//                    }
//                }
//            }
//        }
//
//        stopBottomIndicatorView(spinner: spinner)
//    }

    /// 셀 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, perform in
            let currentSection = self.dataSource.sectionModels[indexPath.section]
            let currentItem = currentSection.items[indexPath.row]

            guard let id = currentItem.id else { return }
            self.viewModel.dbManager.deleteInquireHistory(todoId: id)

            self.viewModel.removeTodo(data: currentItem, completion: {
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
