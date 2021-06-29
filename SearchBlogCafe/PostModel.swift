//
//  PostModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import Foundation

struct PostModel {
    let type: FilterType
    let name: String
    let contents: String
    let date: Date
    let thumbnail: Data?
    let title: String
    let url: String
    
    var isRead = false
    var typeString: String {
        if type == FilterType.blog {
            return "Blog"
        } else if type == FilterType.cafe {
            return "Cafe"
        }
        return ""
    }
}
