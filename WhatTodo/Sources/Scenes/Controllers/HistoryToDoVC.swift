//
//  HistoryToDoVC.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/5/24.
//

/// Rx
import RxDataSources
import RxSwift

/// Apple
import UIKit

final class HistoryToDoVC: UIViewController {
    typealias InquireSectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfInquireData>

    @IBOutlet weak var tableView: UITableView!

    private var editButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!

    var viewModel = HistoryTodoViewModel()

    private var dataSource: InquireSectionDataSource!

    private var disposeBag = DisposeBag()
}

// MARK: - View Life Cycle

extension HistoryToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - Setup UI

extension HistoryToDoVC {
    private func setupUI() {
        confirmDatasource()
        registerCell()
        confirmTableView()
        confirmNavigationBar()
    }

    private func confirmDatasource() {
        dataSource = InquireSectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifierCollection.historyCell.rawValue, for: indexPath) as? HistoryCell else { return UITableViewCell() }

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
        let todoCell = UINib(nibName: IdentifierCollection.historyCell.rawValue, bundle: nil)
        tableView.register(todoCell, forCellReuseIdentifier: IdentifierCollection.historyCell.rawValue)
    }

    private func confirmTableView() {
        tableView.bounces = false
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .singleLine
        tableView.indicatorStyle = .default
    }

    private func confirmNavigationBar() {
        editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: nil)

        let backImage = UIImage(systemName: "chevron.left")
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: nil)

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = editButton
    }
}

// MARK: - Binding

extension HistoryToDoVC {
    private func bind() {
        navigationBarBind()
    }

    private func navigationBarBind() {
        editButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: 편집 버튼 눌렀다!!")
            })
            .disposed(by: disposeBag)

        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
