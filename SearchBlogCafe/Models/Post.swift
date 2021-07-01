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
    var typeString: String {
        if type.rawValue == Filter.blog.rawValue {
            return "Blog"
        } else if type.rawValue == Filter.cafe.rawValue {
            return "Cafe"
        }
        return ""
    }
    
    var thumbnailData: Data? {
        var data: Data?
        if let url = URL(string: thumbnail) {
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Failed to get thumbnail data from url. error = \(error.localizedDescription)")
            }
        }
        return data
    }
}
