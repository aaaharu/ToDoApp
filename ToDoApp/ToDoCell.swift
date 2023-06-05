//
//  ToDoCell.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//
import SwipeCellKit
import UIKit
import Foundation

@objc protocol SendIdProtocol {
   @objc optional func sendID()
}

protocol ClickedCheckBtn {
    func clickedChangeDone(cell: ToDoCell)
}

class ToDoCell: SwipeTableViewCell {
    
    var indexPath: IndexPath?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    
    var sendDelegate: SendIdProtocol?
    var clickedCheckDelegate: ClickedCheckBtn?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     
    }
    
    @objc fileprivate func updateCellUI(){
        
    }
    
    
    @IBAction func checkBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "-  델리게이트 테스트 ")
        
        // 체크버튼이 눌리면 그 버튼의 인덱스패스에 해당하는 데이터의 id를 가져온다.
        
        (sendDelegate?.sendID ?? { }) ()
        
        clickedCheckDelegate?.clickedChangeDone(cell: self)
        
        
        
                // 버튼을 누르면 didSelecthRowAt 호출
                // 1. 테이블뷰에 접근
                guard let tableView = self.superview as? UITableView else {
                    return
                }
                
                
        
                // 2. 인덱스패스에 접근
                guard let indexPath = tableView.indexPath(for: self) else {
                    return
                }
        
                // 3. didSelectRowAt 호출
                tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        
        
            }
        
        
    }




