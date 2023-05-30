//
//  ViewController.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import UIKit

class ViewController: UIViewController{
    
    
    @IBOutlet weak var plusBtn: UIButton!
 
    
    @IBOutlet weak var tableView: UITableView!
    
    var toDoList: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        let nib = UINib(nibName: "ToDoCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "ToDoCell")
        setupUI()
        toDoCall()
        
        
    }
    
    
    fileprivate func setupUI() {
        plusBtn.clipsToBounds = true
        plusBtn.layer.cornerRadius = 0.5 * plusBtn.bounds.size.width
    }
    
    fileprivate func toDoCall() {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos?page=1&order_by=desc&per_page=10"
        
        guard let url = URL(string: urlString) else { return }
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
         
            guard let data = data else { return }
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                    print(#fileID, #function, #line, "- \(jsonString)")
//            }
            do {
               
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
                
                self.toDoList = todoResponse.data
                
                
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            
            
            
            
        }.resume()
        
        
        
        
    }
    
    
    
    
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell {
                print(#fileID, #function, #line, "- <# 주석 #>")
            
            
            if cell.label != nil {
                    print(#fileID, #function, #line, "- 레이블이 연결되었습니다.")
            } else {
                    print(#fileID, #function, #line, "- 레이블이 연결되지 않았습니다!")
            }
            
            let cellData: Post = toDoList[indexPath.row]
            
            if let title = cellData.title {
                cell.label?.text = title
            } else {
                cell.label?.text = "제목 없음"
            }
           
            return cell
        }
            
            return UITableViewCell()
            
            
            
    }
    
    
    
    
    
    
}

