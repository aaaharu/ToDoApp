//
//  ViewController.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import UIKit

class ViewController: UIViewController{
    
    // 섹션을 위해 데이터를 날짜 순으로 그룹화
    var groupingToDoList: [String: [Post]] = [:]
    var sectionDates: [String] = []
   
    
    // 검색 작업 아이템
    var searchDispatchWorkItem : DispatchWorkItem? = nil
    
    @IBOutlet weak var plusBtn: UIButton!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    
    var toDoList: [Post] = []
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        
        let nib = UINib(nibName: "ToDoCell", bundle: .main)
        myTableView.register(nib, forCellReuseIdentifier: "ToDoCell")
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
                    self.myTableView.reloadData()
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
            self.myTableView.reloadData()
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
                    self.myTableView.reloadData()
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
                
                
                self.makeSectionArray()
                
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            
            
            
            
        }.resume()
        
        
        
        
    }
    
    fileprivate func makeSectionArray(){
        
        //grouping : 값, 뒤에는 key
        // 날짜 key, 그외 데이터 값
        groupingToDoList = Dictionary(grouping: toDoList) { post in
            guard let updated = post.upDated else { return "" }
            return String(updated.prefix(10))
        }
        
        // key순으로 정렬 -> 날짜(key) 섹션 추출 // 내림차순 정렬: sorted().reserved()
        sectionDates = groupingToDoList.keys.sorted().reversed()
        
            print(#fileID, #function, #line, "- toDoList \(groupingToDoList)")
        
            print(#fileID, #function, #line, "- \(sectionDates)")
    }
    
    
    
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionString: String = sectionDates[section]
        
        // 섹션에 있는 날짜별로 키를 가져와서 값 반환?
        return groupingToDoList[sectionString]?.count ?? 0
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
            
            // 날짜 가져오기
            let sectionString = sectionDates[indexPath.section]
            // 날짜별로 데이터 가져오기
            if let posts = groupingToDoList[sectionString] {
                let post = posts[indexPath.row]
                
                // 제목 표시
                if let title = post.title {
                    cell.label?.text = title
                } else {
                    cell.label?.text = "제목 없음"
                }
                
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
            
            }
            
            
            
         
            
         
            
            return cell
        }
        
        return UITableViewCell()
        
        
        
    }

    // 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDates.count
    }
        
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 날짜 표시
        return sectionDates[section]
    }

     
    
    
    
    
    
    
    
}

