//
//  Blog.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import Foundation

public struct BlogData: Codable {
    let documents: [Blog]
}

public struct Blog: Codable {
    let blogname: String
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
}
