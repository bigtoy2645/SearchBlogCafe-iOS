//
//  Cafe.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import Foundation

public struct CafePosts: Decodable {
    let documents: [Cafe]
    let meta: Meta
}

public struct Cafe: Decodable {
    let cafename: String
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
}

public struct Meta: Decodable {
    let total_count: Int
    let pageable_count: Int
    let is_end: Bool
}
