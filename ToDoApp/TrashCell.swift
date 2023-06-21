//
//  TrashCell.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/06/14.
//
import SwipeCellKit
import UIKit

class TrashCell: SwipeTableViewCell {

    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var mainLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
