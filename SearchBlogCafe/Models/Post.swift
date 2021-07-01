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
    let date: Date
    let thumbnail: String
    let title: String
    let url: String
    var isRead = false
}
