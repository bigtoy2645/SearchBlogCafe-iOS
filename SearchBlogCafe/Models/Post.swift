//
//  PostModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import Foundation

struct Post {
    let type: Filter
    let name: String
    let contents: String
    let date: String
    let thumbnail: String
    let title: String
    let url: String
    var isRead = false
}

extension Post: Equatable {
    static let empty = Post(type: Filter.blog, name: "", contents: "", date: "", thumbnail: "", title: "", url: "")
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return (lhs.type.rawValue == rhs.type.rawValue &&
                    lhs.name == rhs.name &&
                    lhs.contents == rhs.contents &&
                    lhs.date == rhs.date &&
                    lhs.thumbnail == rhs.thumbnail &&
                    lhs.title == rhs.title &&
                    lhs.url == rhs.url &&
                    lhs.isRead == rhs.isRead)
    }
}
