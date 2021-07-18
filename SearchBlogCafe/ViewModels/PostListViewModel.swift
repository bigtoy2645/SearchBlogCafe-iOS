//
//  PostListViewModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation
import RxSwift

class PostListViewModel: NSObject {
    var posts = BehaviorSubject<[Post]>(value: [])
    var disposeBag = DisposeBag()
    
    var sort: Sort = .title {
        didSet {
            if oldValue != sort {
                posts.map {
                    return (self.sort == .title ?
                                $0.sorted { $0.title < $1.title } : $0.sorted { $0.date > $1.date })
                }
                .take(1)
                .subscribe(onNext: posts.onNext)
                .disposed(by: disposeBag)
            }
        }
    }
    var filter: Filter = .all
    var page: Int = 0
    var searchKeyword: String = "" {
        didSet {
            page = 0
            if searchKeyword.isEmpty {
                _ = BehaviorSubject.just([]).take(1).subscribe(onNext: posts.onNext)
            } else {
                getPosts()
            }
        }
    }
    
    func setDim(at index: Int) {
        _ = posts.map { allPost in
            var newPosts = [Post]()
            allPost.enumerated().forEach { i, post in
                if i == index {
                    newPosts.append(Post.setRead(post))
                } else {
                    newPosts.append(post)
                }
            }
            return newPosts
        }
        .take(1)
        .subscribe(onNext: posts.onNext)
    }
}

// MARK: - Blog & Cafe 포스트 요청

extension PostListViewModel {
    
    func getPosts() {
        page += 1
        
        let blog = PublishSubject<[Post]>()
        let cafe = PublishSubject<[Post]>()
        
        Observable
            .zip(blog, cafe) { (blogPosts, cafePosts) in
                var newPosts = [Post]()
                do {
                    if self.page > 1 { try newPosts = self.posts.value() }
                    newPosts.append(contentsOf: blogPosts)
                    newPosts.append(contentsOf: cafePosts)
                    if self.sort == .title { newPosts.sort { $0.title < $1.title } }
                    else if self.sort == .date { newPosts.sort { $0.date > $1.date } }
                } catch {
                    print(error.localizedDescription)
                }
                return newPosts
            }
            .take(1)
            .subscribe(onNext: self.posts.onNext)
            .disposed(by: disposeBag)
        
        if (filter.rawValue & Filter.blog.rawValue) != 0 { searchBlogPosts().subscribe(onNext: blog.onNext) } else { blog.onNext([]) }
        if (filter.rawValue & Filter.cafe.rawValue) != 0 { searchCafePosts().subscribe(onNext: cafe.onNext) } else { cafe.onNext([]) }
    }
    
    func searchBlogPosts() -> Observable<[Post]> {
        return KakaoService.searchPostsRx(from: KakaoService.blogURL, for: searchKeyword, page: page)
            .map { data -> [Blog] in
                guard let response = try? JSONDecoder().decode(BlogPosts.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1, userInfo: nil)
                }
                return response.documents
            }
            .map { blogData in
                var blogPosts: [Post] = []
                for data in blogData {
                    let post = Post.fromBlog(data)
                    blogPosts.append(post)
                }
                return blogPosts
            }
    }
    
    func searchCafePosts() -> Observable<[Post]> {
        return KakaoService.searchPostsRx(from: KakaoService.cafeURL, for: searchKeyword, page: page)
            .map { data -> [Cafe] in
                guard let response = try? JSONDecoder().decode(CafePosts.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1, userInfo: nil)
                }
                return response.documents
            }
            .map { cafeData in
                var cafePosts: [Post] = []
                for data in cafeData {
                    let post = Post.fromCafe(data)
                    cafePosts.append(post)
                }
                return cafePosts
            }
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
