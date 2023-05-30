//
//  Model.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import Foundation


struct ToDoResponse: Decodable {
    let data: [Post]
}

// MARK: - Post
struct Post: Decodable {
    let title: String?
    let isDone: Bool?
    
    enum CodingKeys: String, CodingKey {
        case title
        case isDone = "is_done"
    }
//    let xml: XML?
}

// MARK: - XML
struct XML: Codable {
    let name: String?
}
// MARK: - Properties1
struct Properties1: Codable {
    let title, isDone: Count?

    enum CodingKeys: String, CodingKey {
        case title
        case isDone = "is_done"
    }
}

// MARK: - Count
struct Count: Codable {
    let description: String?
    let example: String?
}
