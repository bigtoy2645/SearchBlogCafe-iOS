//
//  PostViewModelTests.swift
//  SearchBlogCafeTests
//
//  Created by yurim on 2021/07/02.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa

class PostViewModelTests: XCTestCase {
    
    private var vm: PostViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        vm = PostViewModel(Post.empty)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_typeString() {
        let type = scheduler.createObserver(String.self)

        vm.typeString
            .bind(to: type)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, Post(type: .blog, name: "", contents: "", date: "", thumbnail: "", title: "", url: "")),
            .next(220, Post(type: .cafe, name: "", contents: "", date: "", thumbnail: "", title: "", url: "")),
            .next(230, Post(type: .blog, name: "", contents: "", date: "", thumbnail: "", title: "", url: ""))
        ])
        .bind(to: vm.post)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(type.events, [
            .next(0, ""),
            .next(210, "Blog"),
            .next(220, "Cafe"),
            .next(230, "Blog")
            ])
    }

    func test_formatDate() {
        let longDate = scheduler.createObserver(String.self)
        let shortDate = scheduler.createObserver(String.self)

        vm.formatDate(style: .long)
            .bind(to: longDate)
            .disposed(by: disposeBag)
        
        vm.formatDate(style: .short)
            .bind(to: shortDate)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, Post(type: .blog, name: "", contents: "", date: "2021-06-02T09:02:20.000+09:00", thumbnail: "", title: "", url: "")),
            .next(220, Post(type: .cafe, name: "", contents: "", date: "2021-07-07T21:22:46.000+09:00", thumbnail: "", title: "", url: "")),
            .next(230, Post(type: .blog, name: "", contents: "", date: "2021-05-01T19:27:05.000+09:00", thumbnail: "", title: "", url: ""))
        ])
        .bind(to: vm.post)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(longDate.events, [
            .next(0, ""),
            .next(210, "2021??? 06??? 02??? ?????? 09??? 02???"),
            .next(220, "2021??? 07??? 07??? ?????? 09??? 22???"),
            .next(230, "2021??? 05??? 01??? ?????? 07??? 27???")
            ])
        
        XCTAssertEqual(shortDate.events, [
            .next(0, ""),
            .next(210, "2021??? 06??? 02???"),
            .next(220, "2021??? 07??? 07???"),
            .next(230, "2021??? 05??? 01???")
            ])
    }

    func test_alpha() {
        let alpha = scheduler.createObserver(Double.self)

        vm.alpha
            .bind(to: alpha)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, Post(type: .blog, name: "", contents: "", date: "", thumbnail: "", title: "", url: "", isRead: true)),
        ])
        .bind(to: vm.post)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(alpha.events, [
            .next(0, 1.0),
            .next(210, 0.3)
            ])
    }
}
