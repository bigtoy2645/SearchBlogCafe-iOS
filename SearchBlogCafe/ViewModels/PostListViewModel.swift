//
//  PostListViewModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation

class PostListViewModel: NSObject {
    private var posts: [Post] = []
    
    var sort: Sort = Sort.title
    var filter: Filter = Filter.all
    var page: Int = 0
    var searchKeyword: String = ""
    var hasNextPage: Bool = false
    
    func numberOfRows() -> Int {
        return posts.count
    }
    
    func post(at index: Int) -> Post? {
        if index >= posts.count { return nil }
        return posts[index]
    }
    
    func updateSearch(keyword: String) {
        self.page = 0
        self.posts.removeAll()
        self.searchKeyword = keyword
    }
    
    func append(posts: [Post]) {
        self.posts.append(contentsOf: posts)
        sortPosts(sort)
    }
    
    func nextPage() -> Int {
        page += 1
        return page
    }
    
    func sortedPosts(_ unsorted: [Post]) -> [Post] {
        var sorted = unsorted
        
        if sort.rawValue == Sort.title.rawValue {
            sorted.sort { $0.title < $1.title }
        } else if sort.rawValue == Sort.date.rawValue {
            sorted.sort { $0.date > $1.date }
        }
        return sorted
    }
    
    func sortPosts(_ sort: Sort) {
        self.sort = sort
        self.posts = sortedPosts(posts)
    }
    
    func setDim(at index: Int) {
        self.posts[index].isRead = true
    }
}

// MARK: - Enum

enum Sort: Int {
    case title = 0
    case date = 1
}

enum Filter: Int {
    case blog = 0x01
    case cafe = 0x02
    case all = 0xFF
}
