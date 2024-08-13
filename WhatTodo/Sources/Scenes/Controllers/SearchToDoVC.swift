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
    @IBOutlet weak var emptyLabel: UILabel!

    private var searchController = UISearchController(searchResultsController: nil)
    private var trashButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!

    private var viewModel = SearchTodoViewModel()

    private var dataSource: SearchSectionDataSource!
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.isEnabled = true
        searchController.isActive = true

        searchController.searchBar.placeholder = "찾고 싶은 할일을 입력해주세요."

        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
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

// MARK: - Binding

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
            .disposed(by: viewModel.disposeBag)

        /// 셀 선택
        tableView.rx.itemSelected
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .bind { (owner, indexPath) in
                let currentSection = owner.dataSource.sectionModels[indexPath.section]
                let currentItem = currentSection.items[indexPath.row]
                owner.pushReadTodoVC(searchText: currentItem.name)
            }
            .disposed(by: viewModel.disposeBag)
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

        viewModel.searchBehaviorSubject
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { (owner, searchs) in

                if searchs.count <= 0 {
                    DispatchQueue.main.async {
                        owner.emptyLabel.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        owner.emptyLabel.isHidden = true
                    }
                }
            }
            .disposed(by: viewModel.disposeBag)
    }

    private func searchBarBind() {
        searchController.searchBar.rx.searchButtonClicked
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let searchText = self.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
                    viewModel.createSearchHistory(searchText: searchText)
                    self.pushReadTodoVC()
                } else {
                    print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchButton 클릭!! 검색어가 없습니다.")
                }
                self.searchController.searchBar.text = ""
            })
            .disposed(by: viewModel.disposeBag)
    }

    private func navigationBarBind() {
        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: viewModel.disposeBag)

        trashButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.deleteAllSearchHistory()
            })
            .disposed(by: viewModel.disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension SearchToDoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - 화면 이동 메서드

extension SearchToDoVC {
    private func pushReadTodoVC() {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.read.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.read.id) as? ReadToDoVC else { return }
        guard let searchText = searchController.searchBar.text else { return }
        vc.viewModel.searchText = searchText
        vc.viewModel.searchModeRelay.accept(true)

        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushReadTodoVC(searchText: String) {
        let sb: UIStoryboard = .init(name: StoryBoardCollection.read.id, bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: ViewControllerCollection.read.id) as? ReadToDoVC else { return }
        vc.viewModel.searchText = searchText
        vc.viewModel.searchModeRelay.accept(true)

        navigationController?.pushViewController(vc, animated: true)
    }
}
