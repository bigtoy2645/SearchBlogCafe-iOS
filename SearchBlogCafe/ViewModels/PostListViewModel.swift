//
//  PostListViewModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation
import RxSwift
import RxCocoa

class PostListViewModel: NSObject {
    var posts = BehaviorRelay<[Post]>(value: [])
    var sort = BehaviorRelay<Sort>(value: .title)
    var searchKeyword = BehaviorRelay<String>(value: "")
    var filter = BehaviorRelay<Filter>(value: .all)
    var filterList = ["All", "Blog", "Cafe"]
    
    var disposeBag = DisposeBag()
    
    private var page: Int = 0
    
    override init() {
        super.init()
        
        sort
        .subscribe(onNext: { sort in
            self.posts.map {
                return (sort == .title ?
                            $0.sorted { $0.title < $1.title } : $0.sorted { $0.date > $1.date })
            }
            .take(1)
            .subscribe(onNext: self.posts.accept(_:))
            .disposed(by: self.disposeBag)
        })
        .disposed(by: disposeBag)
        
        searchKeyword
            .subscribe(onNext: { keyword in
                self.page = 0
                if keyword.isEmpty {
                    _ = BehaviorSubject.just([]).take(1).subscribe(onNext: self.posts.accept(_:))
                } else {
                    self.getPosts()
                }
            })
            .disposed(by: disposeBag)
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
        .subscribe(onNext: posts.accept(_:))
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
                if self.page > 1 { newPosts = self.posts.value }
                newPosts.append(contentsOf: blogPosts)
                newPosts.append(contentsOf: cafePosts)
                if self.sort.value == .title { newPosts.sort { $0.title < $1.title } }
                else { newPosts.sort { $0.date > $1.date } }
                return newPosts
            }
            .take(1)
            .subscribe(onNext: self.posts.accept(_:))
            .disposed(by: disposeBag)
        
        if filter.value != .cafe { searchBlogPosts().subscribe(onNext: blog.onNext) } else { blog.onNext([]) }
        if filter.value != .blog { searchCafePosts().subscribe(onNext: cafe.onNext) } else { cafe.onNext([]) }
    }
    
    func searchBlogPosts() -> Observable<[Post]> {
        return KakaoService.searchPostsRx(from: KakaoService.blogURL, for: searchKeyword.value, page: page)
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
        return KakaoService.searchPostsRx(from: KakaoService.cafeURL, for: searchKeyword.value, page: page)
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
    case all = 0
    case blog = 1
    case cafe = 2
}
