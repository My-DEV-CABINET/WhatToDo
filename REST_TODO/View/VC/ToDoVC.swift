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

enum Identifier: String {
    case todoCell = "ToDoCell"
}

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

final class ToDoVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var hiddenButton: UIBarButtonItem!

    private var viewModel = ToDoViewModel()
    private var searchVC: UISearchController!
    private var refreshControl: UIRefreshControl!

    typealias ToDoSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>

    lazy var dataSource: ToDoSectionDataSource = {
        let db = ToDoSectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.todoCell.rawValue, for: indexPath) as? ToDoCell else { return UITableViewCell() }
                guard let id = item.id else { return UITableViewCell() }
                cell.data = item

                // isDone 스위치 이벤트
                cell.checkHandler = { [weak self] data in
                    guard let title = data.title else { return }
                    guard let isDone = data.isDone else { return }
                    guard let id = data.id else { return }

                    self?.viewModel.editTodo(title: title, isDone: isDone, id: id)
                }

                // 북마크 스위치 이벤트
                cell.favoriteHandler = { [weak self] id in
                    guard let exist = self?.viewModel.dbManager.fetchFavoriteByID(id: id) else { return }

                    if exist {
                        _ = self?.viewModel.dbManager.deleteFavorite(id: id)

                    } else {
                        _ = self?.viewModel.dbManager.insertFavorite(id: id)
                    }
                }

                cell.configure(data: item, isExistFavorite: self.viewModel.dbManager.fetchFavoriteByID(id: id))
                return cell
            })

        db.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }

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

extension ToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.requestGETTodos(completion: {})
    }
}

// MARK: - View Setting 관련 메서드 모음

extension ToDoVC {
    private func setupUI() {
        view.backgroundColor = .white
        registerCell()
        confirmTableView()
        confirmRefreshControl()
        confirmSearchVC()
        confirmAddButton()

        /// Binding
        bind()
    }

    /// Xib 셀 등록
    private func registerCell() {
        let todoCell = UINib(nibName: Identifier.todoCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: Identifier.todoCell.rawValue)
    }

    /// Alert 페이지
    private func showBlankMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAlert = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            completion()
        }
        alert.addAction(confirmAlert)
        present(alert, animated: true)
    }

    /// Floatting 버튼 구성 및 화면 이동 로직
    private func confirmAddButton() {
        addButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            pushDetailVC()
        }), for: .touchUpInside)
    }

    /// DetailVC 로 화면 이동 처리
    private func pushDetailVC() {
        let sb: UIStoryboard = .init(name: "DetailToDo", bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: "DetailToDoVC") as? DetailToDoVC else { return }
        vc.viewModel = DetailToDoViewModel()
        vc.viewModel.userAction = .add

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

extension ToDoVC {
    private func bind() {
        // RxDataSource에 데이터 주입
        viewModel.todoBehaviorRelay
            .map { todos in
                // CreatedAt 기준으로 Dictionary 생성
                let groupedDictionary = Dictionary(grouping: todos) { todo in
                    return todo.createdAt?.dateFormatterForDate() ?? ""
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

        // TableView Cell 선택
        tableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .bind { [weak self] indexPath in
                guard let self = self else { return }

                let currentSection = self.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]

                guard let id = currentItem.id else { return }

                SeenManager.shared.insertSeenList(id: id)

                let sb: UIStoryboard = .init(name: "DetailToDo", bundle: nil)
                guard let vc = sb.instantiateViewController(identifier: "DetailToDoVC") as? DetailToDoVC else { return }
                vc.viewModel = DetailToDoViewModel()
                vc.viewModel.todo = currentItem
                vc.viewModel.userAction = .edit

                vc.eventHandler = { [weak self] _ in
                    let customQueue = DispatchQueue(label: "eventHandler-EDIT")
                    customQueue.async {
                        self?.viewModel.requestGETTodos(completion: {})
                    }
                }

                let navigationVC = UINavigationController(rootViewController: vc)
                self.present(navigationVC, animated: true)

                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            .disposed(by: viewModel.disposeBag)

        // TableView Cell 삭제
        tableView.rx.itemDeleted
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { section, indexPath in
                let currentSection = section.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]
                guard let id = currentItem.id else { return }
                self.viewModel.removeTodo(data: currentItem, completion: {
                    _ = self.viewModel.dbManager.deleteFavorite(id: id)
                })
            })
            .disposed(by: viewModel.disposeBag)

        // TableView RefreshControl 이벤트 처리
        refreshControl.rx.controlEvent(.valueChanged)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.viewModel.resetPage()

                    if self?.searchVC.isActive == true {
                        guard let text = self?.searchVC.searchBar.text else { return }

                        let customQueue = DispatchQueue(label: "refresh")
                        customQueue.async {
                            self?.viewModel.searchTodo(query: text, completion: { [weak self] _ in
                                DispatchQueue.main.async {
                                    self?.refreshControl.endRefreshing()
                                }
                            })
                        }

                    } else {
                        let customQueue = DispatchQueue(label: "refresh")
                        customQueue.async {
                            self?.viewModel.requestGETTodos(completion: {
                                DispatchQueue.main.async {
                                    self?.refreshControl.endRefreshing()
                                }
                            })
                        }
                    }

                    self?.viewModel.paginationRelay.accept(false)
                }
            })
            .disposed(by: viewModel.disposeBag)

        // SearchBar 입력 이벤트 처리
        searchVC.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] text in
                let customQueue = DispatchQueue(label: "searchBar")
                customQueue.async {
                    self?.viewModel.resetPage()
                    self?.viewModel.searchTodo(query: text, completion: { [weak self] todos in
                        if todos.count == 0 {
                            DispatchQueue.main.async {
                                self?.showBlankMessage(title: "찾은 건수 \(todos.count)개", message: "검색 결과를 찾을 수 없습니다.", completion: {
                                    self?.searchVC.searchBar.text = ""
                                    self?.searchVC.searchBar.becomeFirstResponder()
                                })
                            }
                        }
                    })
                }

                DispatchQueue.main.async {
                    self?.tableView.setContentOffset(.zero, animated: true)
                }
            })
            .disposed(by: viewModel.disposeBag)

        // SearchBar 취소 이벤트 처리
        searchVC.searchBar.rx.cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView.setContentOffset(.zero, animated: true)
                self?.searchVC.searchBar.text = ""
                self?.viewModel.resetPage()

                let customQueue = DispatchQueue(label: "searchBarCancel")
                customQueue.async {
                    self?.viewModel.requestGETTodos(completion: {
                        DispatchQueue.main.async {
                            self?.viewModel.paginationRelay.accept(false)
                        }
                    })
                }
                self?.searchVC.searchBar.resignFirstResponder()
            })
            .disposed(by: viewModel.disposeBag)

        // 스크롤 이벤트 처리
        tableView.rx.didScroll
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let currentOffset = self.tableView.contentOffset.y
                let tableViewHeight = self.tableView.frame.size.height
                let contentHeight = self.tableView.contentSize.height

                let paginationOffset = (contentHeight - tableViewHeight - 100) * 0.75

                if currentOffset > paginationOffset, self.viewModel.paginationRelay.value == false {
                    self.viewModel.increasePage()
                    self.viewModel.paginationRelay.accept(true)
                }
            })
            .disposed(by: viewModel.disposeBag)

        // 페이지네이션 처리 - 비동기 이벤트 호출 처리
        viewModel.validPagination
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] valid in
                DispatchQueue.main.async {
                    if valid == true, self?.viewModel.paginationRelay.value == true {
                        if self?.searchVC.isActive == true {
                            // 서치바 동작 상태일 때
                            guard let text = self?.searchVC.searchBar.text else { return }
                            let customQueue = DispatchQueue(label: "validPagination")
                            customQueue.async {
                                self?.viewModel.requestMoreQueryTodos(query: text) {
                                    DispatchQueue.main.async {
                                        self?.viewModel.paginationRelay.accept(false)
                                    }
                                }
                            }
                        } else {
                            // 서치바 동작 상태 아닐 때
                            let customQueue = DispatchQueue(label: "validPagination")
                            customQueue.async {
                                self?.viewModel.requestMoreTodos {
                                    DispatchQueue.main.async {
                                        self?.viewModel.paginationRelay.accept(false)
                                    }
                                }
                            }
                        }
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)

        // 완료 보이기 이벤트 전달
        hiddenButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let isHidden = self?.viewModel.hiddenRelay.value else { return }
                self?.viewModel.hiddenRelay.accept(!isHidden)
            }
            .disposed(by: viewModel.disposeBag)

        // 완료 보이기 여부에 따라서 버튼명 변경 및 Todos 데이터 호출
        viewModel.validHidden
            .drive(onNext: { [weak self] title in
                self?.hiddenButton.title = title
                self?.tableView.setContentOffset(.zero, animated: true)
                self?.viewModel.resetPage()
                let customQueue = DispatchQueue(label: "validHidden")
                if self?.searchVC.isActive == true {
                    guard let text = self?.searchVC.searchBar.text else { return }
                    // 검색창 활성화
                    customQueue.async {
                        self?.viewModel.searchTodo(query: text, completion: { [weak self] _ in })
                    }
                } else {
                    // 검색창 비활성화
                    customQueue.async {
                        self?.viewModel.requestGETTodos(completion: {})
                    }
                }

                self?.viewModel.paginationRelay.accept(false)

            })
            .disposed(by: viewModel.disposeBag)

        // ViewModel todoBehaviorRelay 이벤트 처리
        viewModel.todoBehaviorRelay
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] todos in
                self?.tableView.reloadData()
            }, onError: { error in
                print("#### Line: \(#line) \(error)")
            })
            .disposed(by: viewModel.disposeBag)
    }
}
