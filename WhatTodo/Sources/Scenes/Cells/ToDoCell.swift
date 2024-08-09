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
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    
    /// CheckHandler 방식 변경 필요
    var checkActionObservable: Observable<(id: Int, isDone: Bool)> = Observable.empty()
    var disposeBag = DisposeBag()
   
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
        disposeBag = DisposeBag()
    }
    
    private func confirmCheckButton() {
        checkActionObservable = checkButton.rx.tap
            .map { [weak self] in
                guard let self = self, let id = self.data?.id, let isDone = self.data?.isDone else {
                    return (id: 0, isDone: false)
                }
                return (id: id, isDone: !isDone)
            }
    }
    
    func configure(data: ToDoData, isInquire: Bool) {
        guard let isDone = data.isDone else { return }
        baseView.layer.cornerRadius = 10
        
        titleLabel.text = data.title
        dateLabel.text = data.updatedAt?.dateFormatterForTime()
        
        historyLabel.isHidden = !isInquire
        
        let checkImage = isDone ? "checkmark.circle.fill" : "circle"
        checkButton.setImage(UIImage(systemName: checkImage), for: .normal)
    }
}
