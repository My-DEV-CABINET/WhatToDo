//
//  ToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

/// Rx
import RxDataSources
import RxSwift

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
    @IBOutlet weak var searchbar: UISearchBar!

    private var viewModel = ToDoViewModel()

    typealias ToDoSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>

    let dataSource: ToDoSectionDataSource = {
        let db = ToDoSectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.todoCell.rawValue, for: indexPath) as? ToDoCell else { return UITableViewCell() }
                cell.configure(data: item)
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
        viewModel.requestGETTodos()
    }
}

// MARK: - View Setting 관련 메서드 모음

extension ToDoVC {
    private func setupUI() {
        view.backgroundColor = .white
        registerCell()
        confirmTableView()
        confirmSearchBar()
        confirmAddButton()

        /// Binding
        bind()
    }

    /// Xib 셀 등록
    private func registerCell() {
        let todoCell = UINib(nibName: Identifier.todoCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: Identifier.todoCell.rawValue)
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
            self?.viewModel.requestGETTodos()
        }

        let navigationVC = UINavigationController(rootViewController: vc)
        present(navigationVC, animated: true)
    }

    private func confirmTableView() {
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .singleLine
        tableView.indicatorStyle = .default
    }

    private func confirmSearchBar() {
        searchbar.delegate = self
        searchbar.setShowsCancelButton(true, animated: true)
    }
}

// MARK: - ViewModel Rx Binding 관련 처리 메서드 모음

extension ToDoVC {
    private func bind() {
        // RxDataSource에 데이터 주입
        viewModel.todosSubject
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
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] indexPath in
                guard let self = self else { return }

                let currentSection = self.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]

                let sb: UIStoryboard = .init(name: "DetailToDo", bundle: nil)
                guard let vc = sb.instantiateViewController(identifier: "DetailToDoVC") as? DetailToDoVC else { return }
                vc.viewModel = DetailToDoViewModel()
                vc.viewModel.todo = currentItem
                vc.viewModel.userAction = .edit

                vc.eventHandler = { [weak self] _ in
                    self?.viewModel.requestGETTodos()
                }

                let navigationVC = UINavigationController(rootViewController: vc)
                self.present(navigationVC, animated: true)

                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: viewModel.disposeBag)

        // TableView Cell 삭제
        tableView.rx.itemDeleted
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind { section, indexPath in
                let currentSection = section.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]
                self.viewModel.removeTodo(data: currentItem)
                self.viewModel.requestGETTodos()
            }
            .disposed(by: viewModel.disposeBag)

        // TodoSubject 에 이벤트 발생시, TableView Reload
        viewModel.todosSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: viewModel.disposeBag)

        // SearchBar 입력 이벤트 처리
        searchbar.rx.text.orEmpty
            .asDriver()
            .debounce(.seconds(1))
            .drive(onNext: { text in
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: \(text)")
                self.viewModel.searchTodo(query: text)
            })
            .disposed(by: viewModel.disposeBag)

        // SearchBar 취소 이벤트 처리
        searchbar.rx.cancelButtonClicked
            .asDriver()
            .drive(onNext: {
                self.searchbar.text = ""
                self.viewModel.requestGETTodos()
                self.searchbar.resignFirstResponder()
            })
            .disposed(by: viewModel.disposeBag)

        // TableView 스크롤 이벤트 처리
        tableView.rx.didScroll
            .asDriver()
            .map { self.tableView.contentOffset }
            .drive(onNext: { event in
                print("#### \(event.y) :: \(self.tableView.frame.height * 0.8)")
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - SearchBar Delegate 관련 모음

extension ToDoVC: UISearchBarDelegate {}
