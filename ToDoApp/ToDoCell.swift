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
    var id: Int = 0
    var testIsDone: Bool = false
    
    var getVCBoolValue: Bool = false
    var getIndexPath: IndexPath?
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    
    var sendDelegate: SendIdProtocol?
    var clickedCheckDelegate: ClickedCheckBtn?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(makeUI), name: Notification.Name("VCsendBoolValue"), object: nil)
        
    }
    
    @objc fileprivate func updateCellUI(){
        
    }
    
    
    @IBAction func checkBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "-  메서드 테스트 \(self.indexPath) ")
        
        // 체크버튼이 눌리면 그 버튼의 인덱스패스에 해당하는 데이터의 id를 가져온다.
        
        (sendDelegate?.sendID ?? { }) ()
        
        
        
        
        
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
        
        // 3-2. 선택한 셀의 ID값을 VC로 보낸다.
        let userInfo = ["indexPath": indexPath]
        NotificationCenter.default.post(name: Notification.Name("toggleBoolBtn"), object: nil, userInfo: userInfo)
        
        
        
        
    
        
        
        
    }
    
    @objc fileprivate func makeUI(_ notification: Notification) {
        
            print(#fileID, #function, #line, "-  메이크유아이 발동!!")
        
      
            
        if let data = notification.userInfo as? [String: Any] {
                
            getVCBoolValue = data["bool"] as? Bool ?? false
            getIndexPath = data["indexPath"] as? IndexPath
            
            guard let unWrappedGetIndexPath = getIndexPath else { return }
            
            print(#fileID, #function, #line, "- <# 주석 #>")
            
            guard let tableView = self.superview as? UITableView else {
                return
            }

            if let cell = tableView.cellForRow(at: unWrappedGetIndexPath) as? ToDoCell {
                
                if  getVCBoolValue{
                    cell.checkBtn.configuration?.baseForegroundColor = .black
                    // 취소선
                    let strikeThroughTask = NSMutableAttributedString(string: cell.label.text ?? "")
                    strikeThroughTask.addAttributes([
                        NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        NSAttributedString.Key.strikethroughColor: UIColor.darkGray,
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)
                    ], range: NSMakeRange(0, strikeThroughTask.length))
                    cell.label?.attributedText = strikeThroughTask
                } else {
                    cell.checkBtn.configuration?.baseForegroundColor = .lightGray
                    let originalString = cell.label.text ?? ""
                    let attributedString = NSMutableAttributedString(string: originalString)
                    attributedString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributedString.length))
                    attributedString.removeAttribute(NSAttributedString.Key.strikethroughColor, range: NSMakeRange(0, attributedString.length))
                    attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17.0), range: NSMakeRange(0, attributedString.length))
                    cell.label?.attributedText = attributedString
                    
                }
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
