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
    typealias HistorySectionDataSource = RxTableViewSectionedReloadDataSource<SectionOfHistoryData>

    @IBOutlet weak var tableView: UITableView!

    private var editButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!

    var viewModel = HistoryTodoViewModel()

    private var dataSource: HistorySectionDataSource!

    private var disposeBag = DisposeBag()
}

// MARK: - View Life Cycle

extension HistoryToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()

        viewModel.fetchTodoHistory()
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
        dataSource = HistorySectionDataSource(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifierCollection.historyCell.rawValue, for: indexPath) as? HistoryCell else { return UITableViewCell() }

                let editMode = self.viewModel.editRealy.value
                cell.configure(data: item, editMode: editMode)

                cell.deleteActionObservable
                    .withUnretained(self)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe { (owner, name) in
                        owner.viewModel.deleteTodoHistory(name: name)
                    }
                    .disposed(by: cell.disposeBag)

                cell.backgroundColor = .white
                cell.selectionStyle = .none
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
        navigationItem.rightBarButtonItem = editButton

        let backImage = UIImage(systemName: "chevron.left")
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: nil)

        navigationItem.leftBarButtonItem = backButton
    }
}

// MARK: - Binding

extension HistoryToDoVC {
    private func bind() {
        viewModelBind()
        tableViewBind()
        navigationBarBind()
    }

    private func viewModelBind() {
        viewModel.historyBehaviorSubject
            .map { todoHistories in
                guard !todoHistories.isEmpty else {
                    return [SectionOfHistoryData(header: "할일 내역", items: [])]
                }

                let sortedKeys = todoHistories.sorted(by: { $0.created > $1.created })

                return [SectionOfHistoryData(header: "할일 내역", items: sortedKeys)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)

        viewModel.editRealy
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { (owner, editMode) in
                let newTitle = editMode ? "완료" : "편집"
                owner.editButton.title = newTitle
                owner.tableView.reloadData()
            }
            .disposed(by: viewModel.disposeBag)
    }

    private func tableViewBind() {
        tableView.rx.setDelegate(self)
            .disposed(by: viewModel.disposeBag)
    }

    private func navigationBarBind() {
        editButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let currentEditStatus = self.viewModel.editRealy.value
                self.viewModel.editRealy.accept(!currentEditStatus)
            })
            .disposed(by: disposeBag)

        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                viewModel.updateAllTodoHistory()
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension HistoryToDoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
