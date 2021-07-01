//
//  Blog.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import Foundation

struct BlogPosts: Decodable {
    let documents: [Blog]
    let meta: Meta
}

struct Blog: Decodable {
    let blogname: String
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
}
