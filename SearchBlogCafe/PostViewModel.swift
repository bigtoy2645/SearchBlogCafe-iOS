//
//  PostViewModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation

class PostViewModel: NSObject {
    private var post: Post
    
    init(_ post: Post) {
        self.post = post
    }
    
    var typeString: String {
        if post.type.rawValue == Filter.blog.rawValue {
            return "Blog"
        } else if post.type.rawValue == Filter.cafe.rawValue {
            return "Cafe"
        }
        return ""
    }
    
    var alpha: Double {
        return post.isRead ? 0.3 : 1.0
    }
    
    var titleString: String {
        return htmlEscaped(post.title)
    }
    
    var contentString: String {
        return htmlEscaped(post.contents)
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
        let date = DateUtil.parseDate(post.date)
        return DateUtil.formatDate(date, style: style)
    }
    
    /* HTML 태그 제거 */
    private func htmlEscaped(_ htmlString: String) -> String {
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
