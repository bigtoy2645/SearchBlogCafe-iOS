//
//  SearchBlogCafeTests.swift
//  SearchBlogCafeTests
//
//  Created by yurim on 2021/06/28.
//

import XCTest
import RxTest
import RxSwift

class PostListViewModelTests: XCTestCase {
    private var vm: PostListViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        vm = PostListViewModel()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_sortPosts() {
        vm.posts.accept([Post(type: .all, name: "", contents: "", date: "2021-06-08T16:40:17.000+09:00", thumbnail: "", title: "1", url: ""),
                         Post(type: .all, name: "", contents: "", date: "2021-06-29T17:42:48.000+09:00", thumbnail: "", title: "3", url: ""),
                         Post(type: .all, name: "", contents: "", date: "2021-01-22T00:06:13.000+09:00", thumbnail: "", title: "2", url: "")])
        
        let sortedPost = scheduler.createObserver([Post].self)
        
        vm.posts
            .bind(to: sortedPost)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, .title),
            .next(220, .date)
        ])
        .bind(to: vm.sort)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(sortedPost.events, [
            .next(0, [Post(type: .all, name: "", contents: "", date: "2021-06-08T16:40:17.000+09:00", thumbnail: "", title: "1", url: ""),
                      Post(type: .all, name: "", contents: "", date: "2021-06-29T17:42:48.000+09:00", thumbnail: "", title: "3", url: ""),
                      Post(type: .all, name: "", contents: "", date: "2021-01-22T00:06:13.000+09:00", thumbnail: "", title: "2", url: "")]),
            .next(210, [Post(type: .all, name: "", contents: "", date: "2021-06-08T16:40:17.000+09:00", thumbnail: "", title: "1", url: ""),
                        Post(type: .all, name: "", contents: "", date: "2021-01-22T00:06:13.000+09:00", thumbnail: "", title: "2", url: ""),
                        Post(type: .all, name: "", contents: "", date: "2021-06-29T17:42:48.000+09:00", thumbnail: "", title: "3", url: "")]),
            .next(220, [Post(type: .all, name: "", contents: "", date: "2021-06-29T17:42:48.000+09:00", thumbnail: "", title: "3", url: ""),
                        Post(type: .all, name: "", contents: "", date: "2021-06-08T16:40:17.000+09:00", thumbnail: "", title: "1", url: ""),
                        Post(type: .all, name: "", contents: "", date: "2021-01-22T00:06:13.000+09:00", thumbnail: "", title: "2", url: "")])
            ])
    }
    
    func test_searchKeyword() {
        let searchPost = scheduler.createObserver([Post].self)
        
        vm.posts
            .bind(to: searchPost)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, "")
        ])
        .bind(to: vm.searchKeyword)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(searchPost.events, [
            .next(0, []),
            .next(210, [])
        ])
    }
    
    func test_dim() {
        vm.posts.accept([Post.empty, Post.empty, Post.empty])
        
        let dimPost = scheduler.createObserver([Post].self)
        
        vm.posts
            .bind(to: dimPost)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, 1)
        ])
        .subscribe(onNext: { self.vm.setDim(at: $0) })
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(dimPost.events, [
            .next(0, [Post.empty, Post.empty, Post.empty]),
            .next(210, [Post(type: .all, name: "", contents: "", date: "", thumbnail: "", title: "", url: "", isRead: false),
                        Post(type: .all, name: "", contents: "", date: "", thumbnail: "", title: "", url: "", isRead: true),
                        Post(type: .all, name: "", contents: "", date: "", thumbnail: "", title: "", url: "", isRead: false)])
            ])
    }
}
