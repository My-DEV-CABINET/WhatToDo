//
//  FilterViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 6/30/24.
//

// Rx
import RxCocoa
import RxSwift

// Apple
import UIKit

final class FilterToDoVC: UIViewController {
    @IBOutlet weak var hiddenSegmentControl: UISegmentedControl!
    @IBOutlet weak var orderSegmentControl: UISegmentedControl!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var baseView: UIView!

    let eventSubject = PublishSubject<Void>()
    var disposeBag = DisposeBag()

    private var selectedDone: String?
    private var selectedOrder: String?
}

// MARK: - View Life Cycle

extension FilterToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - Setting Up UI

extension FilterToDoVC {
    private func setupUI() {
        initialSegmentValue()
        baseView.layer.cornerRadius = 10
        bind()
    }

    private func initialSegmentValue() {
        let orderValue = SettingManager.shared.order
        orderSegmentControl.selectedSegmentIndex = convertOrderTag(value: orderValue)
        selectedOrder = orderValue

        let doneValue = SettingManager.shared.done
        hiddenSegmentControl.selectedSegmentIndex = convertDoneTag(value: doneValue)
        selectedDone = doneValue
    }

    private func convertFilterOption(title: String) -> Done {
        switch title {
        case "모두보기":
            return .all
        case "완료":
            return .onlyCompleted
        case "미완료":
            return .onlyNonCompleted
        default:
            return .all
        }
    }

    private func convertOrderOption(title: String) -> Order {
        switch title {
        case "내림차순":
            return .desc
        case "오름차순":
            return .asc
        default:
            return .desc
        }
    }

    private func convertDoneTag(value: String) -> Int {
        switch value {
        case Done.all.rawValue:
            return 0
        case Done.onlyCompleted.rawValue:
            return 1
        case Done.onlyNonCompleted.rawValue:
            return 2
        default:
            return 0
        }
    }

    private func convertOrderTag(value: String) -> Int {
        switch value {
        case Order.desc.rawValue:
            return 0
        case Order.asc.rawValue:
            return 1
        default:
            return 0
        }
    }
}

// MARK: - View Binding

extension FilterToDoVC {
    private func bind() {
        // Confirm Button
        confirmButton.rx.tap
            .asDriver()
            .drive { _ in
                guard let done = self.selectedDone else { return }
                guard let order = self.selectedOrder else { return }

                SettingManager.saveDoneAndOrder(done: done, order: order)
                self.eventSubject.onNext(())
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        // Cancel Button
        cancelButton.rx.tap
            .asDriver()
            .drive { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        // Done SegmentControl
        hiddenSegmentControl.rx.value.changed
            .asDriver()
            .drive { [weak self] _ in
                guard let self = self else { return }
                let selectedIndex = self.hiddenSegmentControl.selectedSegmentIndex
                let selectedTitle = self.hiddenSegmentControl.titleForSegment(at: selectedIndex) ?? "No title"

                selectedDone = convertFilterOption(title: selectedTitle).rawValue
            }
            .disposed(by: disposeBag)

        // Order SegmentControl
        orderSegmentControl.rx.value.changed
            .asDriver()
            .drive { [weak self] _ in
                guard let self = self else { return }
                let selectedIndex = self.orderSegmentControl.selectedSegmentIndex
                let selectedTitle = self.orderSegmentControl.titleForSegment(at: selectedIndex) ?? "No title"

                selectedOrder = convertOrderOption(title: selectedTitle).rawValue
            }
            .disposed(by: disposeBag)
    }
}
