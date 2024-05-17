//
//  ToDoCell.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/17/24.
//

import UIKit

enum Identifier: String {
    case todoCell = "ToDoCell"
}

final class ToDoCell: UITableViewCell {
    static let identifier = Identifier.todoCell.rawValue

    let checkBox = UIButton(frame: .zero)
    let descriptionLabel = UILabel(frame: .zero)
    let dateLabel = UILabel(frame: .zero)
}

// MARK: - Setting ToDoCell

extension ToDoCell {
    private func setupUI() {
        addView()
    }

    private func addView() {
        [checkBox, descriptionLabel, dateLabel].forEach { contentView.addSubview($0) }
    }
}
