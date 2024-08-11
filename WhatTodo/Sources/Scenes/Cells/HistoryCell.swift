//
//  HistoryCell.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/10/24.
//

/// Rx
import RxCocoa
import RxRelay
import RxSwift

/// Apple
import UIKit

final class HistoryCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!

    var deleteActionObservable: Observable<String> = .empty()

    var disposeBag = DisposeBag()
}

// MARK: - Cell Life Cycle

extension HistoryCell {
    /// 셀 초기화시 호출
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// 셀이 안 보일 때
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    func configure(data: TodoHistory, editMode: Bool) {
        titleLabel.text = data.name
        dateLabel.text = data.created.description
        deleteBtn.isHidden = !editMode

        deleteActionObservable = deleteBtn.rx.tap
            .compactMap { _ in
                return data.name
            }
    }
}
