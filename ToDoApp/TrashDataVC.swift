//
//  TrashDataVCViewController.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/06/14.
//

import SwipeCellKit
import UIKit

class TrashDataVC: UIViewController {
    
    var getDeleteList: [Post] = []
    var sendRestoreList: [Post] = []
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            print(#fileID, #function, #line, "- \(getDeleteList)")
        
        
        myTableView.dataSource = self
        
        let nib = UINib(nibName: "TrashCell", bundle: .main)
        
        myTableView.register(nib, forCellReuseIdentifier: "TrashCell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "뒤로 가기", style: .plain, target: self, action: #selector(backBtnClicked))
    }
    
    @objc func backBtnClicked(_ sender: UIBarButtonItem) {
            print(#fileID, #function, #line, "- <# 주석 #>")
        self.navigationController?.dismiss(animated: true)
        self.performSegue(withIdentifier: "BackToFirstVC", sender: self)
                         
    }
    
   
   
                          }


extension TrashDataVC: UITableViewDataSource, SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getDeleteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrashCell", for: indexPath) as? TrashCell else { return UITableViewCell() }
        
        cell.delegate = self
            
        let post: Post = getDeleteList[indexPath.row]
        
        cell.idLabel.text = "ID: \(String(describing: post.id!))"
        cell.mainLable.text = post.title
        
        
        // 날짜 표시
        var time: String = ""
        if var upDate = post.upDated {
            
            print(#fileID, #function, #line, "- \(upDate)")
            
            upDate.removeLast()
            
            print(#fileID, #function, #line, "- \(upDate)")
            
            
            let customDateFormatter = DateFormatter()
            customDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            
            
            if let date = customDateFormatter.date(from: upDate) {
                print(#fileID, #function, #line, "- \(date)")
                time = DateFormatter.localizedString(from: date ?? Date(), dateStyle: .long, timeStyle: .short)
            } else {
                print(#fileID, #function, #line, "- 날짜 변환 실패")
            }
            

            cell.dateLabel?.text = time
            
        } else {
            cell.dateLabel?.text = "시간 없음"
        }
        
        
        
        return cell
    }
    
    
    // 오른쪽 셀 스와이프 - 삭제
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "삭제") { action, indexPath in
                
                
                self.getDeleteList.remove(at: indexPath.row)
                
                self.myTableView.reloadData()
            }
            
            return [deleteAction]
            
        } else if orientation == .left  {
            
            
            
            let editAction = SwipeAction(style: .destructive, title: "복원") {
                action, indexPath in
                
                print(#fileID, #function, #line, "- indexPath.row \(indexPath.row)")
                print(#fileID, #function, #line, "- self.getDeleteList \(self.getDeleteList[indexPath.row])")
                 
                // 복원 보내기
                self.sendRestoreList.append(self.getDeleteList[indexPath.row])
                
                
                // 지우기
                self.getDeleteList.remove(at: indexPath.row)

                self.myTableView.reloadData()
                
                
            }
            
            editAction.backgroundColor = .systemGreen
            
            return [editAction]
            
        }
        
        return nil
        
    }
    
}
