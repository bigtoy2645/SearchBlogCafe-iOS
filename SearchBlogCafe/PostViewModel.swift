//
//  PostViewModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation

class PostViewModel: NSObject {
    private var post = Post(type: Filter.blog, name: "", contents: "", date: Date(), thumbnail: "", title: "", url: "")
    
    func fetch(post: Post) {
        self.post = post
    }
    
    func typeString() -> String {
        if post.type.rawValue == Filter.blog.rawValue {
            return "Blog"
        } else if post.type.rawValue == Filter.cafe.rawValue {
            return "Cafe"
        }
        return ""
    }
    
    func thumbnailData() -> Data? {
        var data: Data?
        if let url = URL(string: post.thumbnail) {
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Failed to get thumbnail data from url. error = \(error.localizedDescription)")
            }
        }
        return data
    }
    
    func formatDate(style: DateUtil.FormatStyle) -> String {
        return DateUtil.formatDate(post.date, style: style)
    }
}
