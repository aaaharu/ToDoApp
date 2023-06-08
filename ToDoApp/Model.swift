//
//  Model.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import Foundation



struct ItemResponse<T: Decodable>: Decodable {
    let data: T?
    let message: String?
}

struct ItemArrayResponse<T: Decodable>: Decodable {
    let data: [T]
}

struct ToDoItemResponse: Decodable {
    let data: Post?
    let message: String?
}



struct ToDoResponse: Decodable {
    let data: [Post]
}

// MARK: - Post
struct Post: Decodable {
    var id: Int?
    var title: String?
    var isDone: Bool?
    let upDated: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isDone = "is_done"
        case upDated = "updated_at"
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
