//
//  SearchToDoVC.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/3/24.
//

/// Rx
import RxDataSources
import RxSwift

/// Apple
import UIKit

final class SearchToDoVC: UIViewController {
    typealias SearchSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfSearchData>

    @IBOutlet weak var tableView: UITableView!

    private var searchController: UISearchController!
    private var trashButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!

    private var viewModel = SearchTodoViewModel()

    private var dataSource: SearchSectionDataSource!

    private var disposeBag = DisposeBag()
}

// MARK: - View Life Cycle

extension SearchToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()

        viewModel.fetchSearchHistory()
    }
}

// MARK: - Setup UI

extension SearchToDoVC {
    private func setupUI() {
        registerCell()
        confirmDatasource()
        confirmTableView()
        confirmSearchVC()
        confirmNavigationBar()
    }

    private func confirmDatasource() {
        dataSource = SearchSectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifierCollection.searchCell.rawValue, for: indexPath) as? SearchCell else { return UITableViewCell() }

                cell.configure(data: item)

                cell.deleteActionObservable
                    .withUnretained(self)
                    .subscribe(onNext: { (owner, _) in
                        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: Delete Btn 클릭!!")
                        owner.viewModel.deleteSearchHistory(name: item.name)
                    })
                    .disposed(by: cell.disposeBag)

                cell.backgroundColor = .white
                return cell
            })

        dataSource?.canEditRowAtIndexPath = { dataSource, indexPath in
            return false
        }

        dataSource?.canMoveRowAtIndexPath = { dataSource, indexPath in
            return false
        }
    }

    /// Xib 셀 등록
    private func registerCell() {
        /// TableView Cell
        let todoCell = UINib(nibName: IdentifierCollection.searchCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: IdentifierCollection.searchCell.rawValue)
    }

    private func confirmTableView() {
        tableView.bounces = false
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .singleLine
        tableView.indicatorStyle = .default
    }

    private func confirmSearchVC() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "찾고 싶은 할일을 입력해주세요."

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }

    private func confirmNavigationBar() {
        let trashImage = UIImage(systemName: "trash")
        trashButton = UIBarButtonItem(image: trashImage, style: .plain, target: self, action: nil)

        let backImage = UIImage(systemName: "chevron.left")
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: nil)

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = trashButton
    }
}

extension SearchToDoVC {
    private func bind() {
        tableViewBind()
        rxDatasourceBind()
        navigationBarBind()
        searchBarBind()
    }

    private func tableViewBind() {
        /// TableView Delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func rxDatasourceBind() {
        /// RxDataSource에 데이터 주입
        viewModel.searchBehaviorSubject
            .map { searchs in
                // 날짜 정렬
                let sortedKeys = searchs.sorted(by: { $0.created > $1.created })

                return [SectionOfSearchData(header: "최근 검색내역", items: sortedKeys)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
    }

    private func searchBarBind() {
        searchController.searchBar.rx.searchButtonClicked
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let searchText = self.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
                    viewModel.createSearchHistory(searchText: searchText)
                } else {
                    print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchButton 클릭!! 검색어가 없습니다.")
                }
                self.searchController.searchBar.text = ""
            })
            .disposed(by: disposeBag)
    }

    private func navigationBarBind() {
        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        trashButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.deleteAllSearchHistory()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension SearchToDoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
