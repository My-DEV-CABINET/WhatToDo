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

                cell.backgroundColor = .clear
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
        navigationBarBind()
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
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: 전체 삭제 버튼 클릭!!")
            })
            .disposed(by: disposeBag)
    }
}
