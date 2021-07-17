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
    
    static func fromBlog(_ data: Blog) -> Post {
        return Post(type: Filter.blog, name: data.blogname, contents: htmlEscaped(data.contents),
                    date: data.datetime, thumbnail: data.thumbnail, title: htmlEscaped(data.title), url: data.url)
    }
    
    static func fromCafe(_ data: Cafe) -> Post {
        return Post(type: Filter.cafe, name: data.cafename, contents: htmlEscaped(data.contents),
                    date: data.datetime, thumbnail: data.thumbnail, title: htmlEscaped(data.title), url: data.url)
    }
    
    static func setRead(_ post: Post) -> Post {
        var newPost = post
        newPost.isRead = true
        return newPost
    }
    
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
    
    /* HTML 태그 제거 */
    private static func htmlEscaped(_ htmlString: String) -> String {
        guard let encodedData = htmlString.data(using: .utf16) else { return htmlString }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf16.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: options, documentAttributes: nil)
            return attributedString.string
        } catch {
            return htmlString
        }
    }
}
