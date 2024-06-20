////
////  ToDoCell.swift
////  REST_TODO
////
////  Created by 준우의 MacBook 16 on 5/17/24.
////
//

/// Rx
import RxCocoa
import RxRelay
import RxSwift

/// Apple
import UIKit

final class ToDoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var seenLabel: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    /// CheckHandler 방식 변경 필요
    var checkHandler: ((_ data: ToDoData) -> Void)?
    var favoriteHandler: ((_ id: Int) -> Void)?
    
    var data: ToDoData?

    /// 셀 초기화시 호출
    override func awakeFromNib() {
        setup()
    }
    
    /// 셀이 안 보일 때
    override func prepareForReuse() {
        reset()
    }
    
    private func setup() {
        confirmCheckButton()
        confirmFavoriteButton()
    }
    
    private func reset() {
        data = nil
        checkHandler = nil
        favoriteHandler = nil
    }
    
    private func confirmCheckButton() {
        checkButton.addAction(UIAction(handler: { [weak self] _ in
            guard var data = self?.data else { return }
            guard let isDone = data.isDone else { return }
            data.isDone = !isDone
            self?.checkHandler?(data)
        }), for: .touchUpInside)
    }
    
    private func confirmFavoriteButton() {
        favoriteButton.addAction(UIAction(handler: { [weak self] _ in
            guard let id = self?.data?.id else { return }
            self?.favoriteHandler?(id)
        }), for: .touchUpInside)
    }
    
    func configure(data: ToDoData, isExistFavorite: Bool) {
        guard let id = data.id else { return }
        guard let isDone = data.isDone else { return }
        
        titleLabel.text = data.title
        dateLabel.text = data.updatedAt?.dateFormatterForTime()
        
        SeenManager.shared.id = id
        seenLabel.isHidden = SeenManager.shared.existCheckInList
        
        let checkImage = isDone ? "checkmark.square.fill" : "square"
        checkButton.setImage(UIImage(systemName: checkImage), for: .normal)
        
        let favoriteImage = isExistFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: favoriteImage), for: .normal)
    }
}
