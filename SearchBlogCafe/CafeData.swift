//
//  Cafe.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import Foundation

public struct CafeData: Codable {
    let documents: [Cafe]
}

public struct Cafe: Codable {
    let cafename: String
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
}
