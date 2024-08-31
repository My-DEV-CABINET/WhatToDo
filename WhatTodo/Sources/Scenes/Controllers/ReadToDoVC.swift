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
    typealias ToDoSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfToDoData>

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!

    var viewModel = ReadTodoViewModel()
    private var refreshControl: UIRefreshControl!

    private var backButton: UIBarButtonItem!
    private var filterButton: UIBarButtonItem!
    private var searchButton: UIBarButtonItem!
    private var historyButton: UIBarButtonItem!

    private var dataSource: ToDoSectionDataSource!
    private var disposeBag: DisposeBag!

    deinit {
        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoVC deinitialize")
    }
}

// MARK: - View Life Cycle 관련 메서드 모음

extension ReadToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        disposeBag = DisposeBag()
        viewBind()
        tableViewBind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkUnreadMessage()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - View Setting 관련 메서드 모음

extension ReadToDoVC {
    private func setupUI() {
        registerCell()
        confirmDatasource()
        confirmTableView()
        confirmRefreshControl()
        confirmNavigationBarItem()

        /// 화면 터치시, 키보드 내리기
        hideKeyboardWhenTappedAround()
    }

    /// Xib 셀 등록
    private func registerCell() {
        /// TableView Cell
        let todoCell = UINib(nibName: IdentifierCollection.todoCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: IdentifierCollection.todoCell.rawValue)

        /// TableView Header Cell
        let haderCell = UINib(nibName: IdentifierCollection.headerView.rawValue, bundle: nil)
        tableView.register(haderCell, forHeaderFooterViewReuseIdentifier: IdentifierCollection.headerView.rawValue)
    }

    private func confirmDatasource() {
        dataSource = ToDoSectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifierCollection.todoCell.rawValue, for: indexPath) as? ToDoCell else { return UITableViewCell() }

                guard let id = item.id, let title = item.title else { return UITableViewCell() }
                cell.data = item

                /// isDone 스위치 이벤트
                cell.checkActionObservable
                    .withUnretained(self)
                    .subscribe(onNext: { (owner, data) in
                        let (id, isDone) = data

                        var currentSection = owner.dataSource.sectionModels[indexPath.section]

                        if let index = currentSection.items.firstIndex(where: { $0.id == id }) {
                            currentSection.items[index].isDone = isDone
                        }

                        var updatedSections = owner.dataSource.sectionModels
                        updatedSections[indexPath.section] = currentSection

                        owner.dataSource.setSections(updatedSections)
                        owner.viewModel.editTodo(title: title, isDone: data.isDone, id: data.id)

                        UIView.performWithoutAnimation {
                            owner.tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    })
                    .disposed(by: cell.disposeBag)

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

    private func confirmNavigationBarItem() {
        filterButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: nil)
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        historyButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: nil)

        let backImage = UIImage(systemName: "chevron.left")
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: nil)

        navigationItem.leftBarButtonItem = backButton

        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backgroundColor = .clear
        navigationItem.rightBarButtonItems = [historyButton, searchButton, filterButton]
    }

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
                    owner.viewModel.requestGETTodos(completion: {
                        DispatchQueue.main.async {
                            guard let id = owner.viewModel.todos.first?.id else { return }
                            let name = owner.viewModel.makeTodoHistoryTitle(type: .add, id: id)
                            owner.viewModel.createTodoHistory(name: name)
                            owner.viewModel.checkUnreadMessage()
                        }
                    })
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
        viewModelBind()
        rxDatasourceBind()
    }

    private func viewBind() {
        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)

        /// Add 버튼 클릭시, AddVC 로 화면이동
        addButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.pushAddVC()
            })
            .disposed(by: disposeBag)

        /// Filter 버튼 클릭시, FilterVC 로 화면표시
        filterButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.pushFilterVC()
            })
            .disposed(by: disposeBag)

        /// Search 버튼 클릭시, SearchVC 로 화면이동
        searchButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.pushSearchVC()
            })
            .disposed(by: disposeBag)

        /// History 버튼 클릭시, HistoryVC 로 화면이동
        historyButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.pushHistoryVC()
            })
            .disposed(by: disposeBag)
    }

    private func rxDatasourceBind() {
        /// RxDataSource에 데이터 주입
        viewModel.todoBehaviorSubject
            .map { todos in
                DispatchQueue.main.async {
                    self.emptyLabel.isHidden = !todos.isEmpty
                }

                // CreatedAt 기준으로 Dictionary 생성
                let groupedDictionary = Dictionary(grouping: todos) { todo in
                    return todo.updatedAt?.dateFormatterForDate() ?? ""
                }

                // 날짜 정렬
                let sortedKeys = groupedDictionary.keys.sorted(by: { self.viewModel.orderBy == Order.desc.rawValue ? $0 > $1 : $0 < $1 })

                // SectionOfCustomData 생성
                return sortedKeys.map { key in
                    SectionOfToDoData(header: key, items: groupedDictionary[key] ?? [])
                }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
    }

    private func tableViewBind() {
        /// TableView Delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

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

                let sb: UIStoryboard = .init(name: StoryBoardCollection.detail.id, bundle: nil)
                guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.detail.id) as? DetailToDoVC else { return }
                vc.viewModel = DetailTodoViewModel()
                vc.viewModel.todo = currentItem

                let navigationVC = UINavigationController(rootViewController: vc)
                navigationVC.modalPresentationStyle = .pageSheet
                navigationVC.isModalInPresentation = true /// 사용자가 실수로 모달뷰를 닫지 못하도록 처리
                present(navigationVC, animated: true)

                /// EditVC 의 EventHandler 처리
                vc.editSubject
                    .withUnretained(self)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { (owner, valid) in
                        if valid {
                            self.viewModel.resetPage()
                            self.tableView.setContentOffset(.zero, animated: true)

                            customQueue.async {
                                self.viewModel.requestGETTodos(completion: {})
                            }
                        }
                    })
                    .disposed(by: vc.disposeBag)

                /// EditVC 의 DeleteHandler 처리
                vc.deleteSubject
                    .withUnretained(self)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { (owner, valid) in
                        if valid {
                            customQueue.async {
                                self.viewModel.removeTodo(data: currentItem, completion: {
                                    guard let details = currentItem.title else { return }
                                    UNUserNotificationCenter.current().addNotificationRequest(title: "할일 삭제됨", details: details)

                                    DispatchQueue.main.async {
                                        let name = self.viewModel.makeTodoHistoryTitle(type: .delete, id: id)
                                        self.viewModel.createTodoHistory(name: name)
                                        self.viewModel.checkUnreadMessage()
                                    }
                                })
                            }
                        }
                    })
                    .disposed(by: vc.disposeBag)

                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            .disposed(by: disposeBag)

        /// 페이징 처리
        tableView.rx.willDisplayCell
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                guard !viewModel.paginationRelay.value else { return } /// True 이면, API 호출하지 않고, 조기 종료

                let sections = dataSource.sectionModels
                let totalItemsCount = sections.flatMap { $0.items }.count
                let currentIndex = sections.prefix(indexPath.section).flatMap { $0.items }.count + indexPath.row

                let customQueue = DispatchQueue(label: QueueCollection.paging.rawValue)

                if currentIndex == totalItemsCount - 2 {
                    viewModel.increasePage()
                    if !self.viewModel.searchModeRelay.value {
                        // Search 모드가 아닐 때,
                        customQueue.async {
                            self.viewModel.requestMoreTodos { valid in
                                DispatchQueue.main.async {
                                    if !valid, totalItemsCount > 10 {
                                        self.pushAlertVC(title: "알림⚠️", detail: "마지막 페이지에 도달했습니다.", image: "book.pages")
                                        self.viewModel.paginationRelay.accept(true)
                                    }
                                }
                            }
                        }
                    } else {
                        guard let searchText = self.viewModel.searchText else { return }
                        customQueue.async {
                            self.viewModel.requestMoreQueryTodos(query: searchText, completion: { valid in
                                DispatchQueue.main.async {
                                    if !valid, totalItemsCount > 10 {
                                        self.pushAlertVC(title: "알림⚠️", detail: "마지막 페이지에 도달했습니다.", image: "book.pages")
                                        self.viewModel.paginationRelay.accept(true)
                                    }
                                }
                            })
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        /// TableView RefreshControl 이벤트 처리
        refreshControl.rx.controlEvent(.valueChanged)
            .debug("#### Refresh")
            .observe(on: MainScheduler.instance)
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
            .disposed(by: disposeBag)
    }

    private func viewModelBind() {
        viewModel.searchModeRelay
            .withUnretained(self)
            .debug("#### SearchMode")
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (owner, searchMode) in
                owner.backButton.isHidden = !searchMode

                if !searchMode {
                    // SearchMode 가 아닐 때,
                    owner.viewModel.requestGETTodos(completion: {
                        //
                    })
                } else {
                    guard let searchText = owner.viewModel.searchText else { return }
                    owner.viewModel.searchTodo(query: searchText, completion: { _ in
                        //
                    })
                }

            })
            .disposed(by: viewModel.disposeBag)

        viewModel.unReadMessageRealy
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { (owner, unread) in
                if !unread {
                    owner.historyButton.image = UIImage(systemName: "bell")

                } else {
                    // 심볼의 설정
                    let symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.red, .black])
                    let multicolorSymbol = UIImage(systemName: "bell.badge")?.applyingSymbolConfiguration(symbolConfiguration)
                    owner.historyButton.image = multicolorSymbol
                }
            }
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - 장풍 코드 리팩토링 메서드 모음

extension ReadToDoVC {
    /// 검색 결과 아무것도 없을 시, 오류 메시지 VC 표시
    private func returnNonTodosAtSearching(todos: [ToDoData]) {
        if todos.count == 0 {
            showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                self.tableView.setContentOffset(.zero, animated: true)
            })
        }
        return
    }

    /// Refresh Control 동작시, 오류 메시지 VC 표시
    private func returnNonTodosAtRefreshControl(todos: [ToDoData]) {
        if todos.count == 0 {
            showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
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
            pushAlertVC(title: "알림⚠️", detail: "마지막 페이지에 도달했습니다.", image: "book.pages")
            viewModel.paginationRelay.accept(true)
        }
    }
}

// MARK: - UITableViewDelegate 처리

extension ReadToDoVC: UITableViewDelegate {
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
                DispatchQueue.main.async {
                    let name = self.viewModel.makeTodoHistoryTitle(type: .delete, id: id)
                    self.viewModel.createTodoHistory(name: name)
                    self.viewModel.checkUnreadMessage()
                }
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
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: IdentifierCollection.headerView.rawValue) as? HeaderView else { return UIView() }
        header.dateLabel.text = dataSource.sectionModels[section].header
        return header
    }

    /// 헤더 높이 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
