//
//  ViewController.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import UIKit

class ViewController: UIViewController{
    
    // 검색 작업 아이템
    var searchDispatchWorkItem : DispatchWorkItem? = nil
    
    @IBOutlet weak var plusBtn: UIButton!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var toDoList: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        let nib = UINib(nibName: "ToDoCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "ToDoCell")
        setupUI()
        toDoCall()
        
        // 노티 - 수신기 등록
        NotificationCenter.default.addObserver(self, selector: #selector(toDoRecall), name: Notification.Name("CustomNotification"), object: nil)
        
        // 검색
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarInput(_:)), for: .editingChanged)
    }
    
    // 한글 String을 URL로 변환(한글로 query 검색 시 에러 뜸)
    func encodeKoreanToURL(_ KoreanString: String) -> String {
        
    
        let encodedString = KoreanString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return encodedString
    }
    
    @objc fileprivate func searchBarInput(_ searchTextField: UITextField) {
            print(#fileID, #function, #line, "- <# 주석 #>")
        
        let urlQuery: String? = encodeKoreanToURL(searchTextField.text ?? "")
        
        if let query = urlQuery {
            
            // 검색어가 입력되면 기존 작업 취소
            searchDispatchWorkItem?.cancel()
            
            let dispatchWorkItem = DispatchWorkItem(block: {
                // 백그라운드 - 사용자 입력 userInteractive
                DispatchQueue.global(qos: .userInteractive).async {
                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: (searchTextField)")
                    
                    self.callSearchGET(query)
                }
            })
            
            // 기존작업을 나중에 취소하기 위해 메모리 주소 일치 시켜줌
            self.searchDispatchWorkItem = dispatchWorkItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
            
            
            //        searchPhoto(searchInput)
        }
        
    }
    
    
    fileprivate func setupUI() {
        plusBtn.clipsToBounds = true
        plusBtn.layer.cornerRadius = 0.5 * plusBtn.bounds.size.width
        
    }
    
    @objc fileprivate func toDoRecall() {
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
    
    @objc fileprivate func callSearchGET(_ query: String) {
        print(#fileID, #function, #line, "-  주석 ")
        
        self.toDoList.removeAll()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/search?query=\(query)&order_by=desc&page=1&per_page=10"
        
        guard let url = URL(string: urlString) else { return     print(#fileID, #function, #line, "- Url 오류! ")}
        
            print(#fileID, #function, #line, "- \(url)")
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
                print(#fileID, #function, #line, "- <# 주석 #>")
            
            guard let data = data else { return }
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            do {
                
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
            
                self.toDoList = todoResponse.data
                
                print(#fileID, #function, #line, "- \(self.toDoList.count)")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            
            
            
            
        }.resume()
        
        
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
            
//
//            if cell.label != nil {
//                print(#fileID, #function, #line, "- 레이블이 연결되었습니다.")
//            } else {
//                print(#fileID, #function, #line, "- 레이블이 연결되지 않았습니다!")
//            }
            
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

