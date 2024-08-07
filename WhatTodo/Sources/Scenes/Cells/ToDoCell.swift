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
    @IBOutlet weak var historyLabel: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    
    /// CheckHandler 방식 변경 필요
    var checkHandler: ((_ data: ToDoData) -> Void)?
   
    var data: ToDoData?

    /// 셀 초기화시 호출
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /// 셀이 안 보일 때
    override func prepareForReuse() {
        reset()
    }
    
    private func setup() {
        confirmCheckButton()
    }
    
    private func reset() {
        data = nil
        checkHandler = nil
    }
    
    private func confirmCheckButton() {
        checkButton.addAction(UIAction(handler: { [weak self] _ in
            guard var data = self?.data else { return }
            guard let isDone = data.isDone else { return }
            data.isDone = !isDone
            self?.checkHandler?(data)
        }), for: .touchUpInside)
    }
    
    func configure(data: ToDoData, isInquire: Bool) {
        guard let isDone = data.isDone else { return }
        
        titleLabel.text = data.title
        dateLabel.text = data.updatedAt?.dateFormatterForTime()
        
        historyLabel.isHidden = !isInquire
        
        let checkImage = isDone ? "checkmark.square.fill" : "square"
        checkButton.setImage(UIImage(systemName: checkImage), for: .normal)
    }
}
