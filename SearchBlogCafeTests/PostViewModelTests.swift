//
//  PostViewModelTests.swift
//  SearchBlogCafeTests
//
//  Created by yurim on 2021/07/02.
//

import XCTest

class PostViewModelTests: XCTestCase {
    
    func test_typeString() {
        let post = Post(type: Filter.blog, name: "", contents: "", date: "", thumbnail: "", title: "", url: "")
        let vm = PostViewModel(post)
        
        XCTAssertEqual(vm.typeString, "Blog")
    }

    func test_formatDate() {
        let post = Post(type: Filter.blog, name: "", contents: "", date: "2021-06-02T09:02:20.000+09:00", thumbnail: "", title: "", url: "")
        let vm = PostViewModel(post)
        
        XCTAssertEqual(vm.formatDate(style: .long), "2021년 06월 02일 오전 09시 02분")
        XCTAssertEqual(vm.formatDate(style: .short), "2021년 06월 02일")
    }
    
    func test_alpha() {
        var post = Post(type: Filter.blog, name: "", contents: "", date: "", thumbnail: "", title: "", url: "")
        post.isRead = true
        let vm = PostViewModel(post)
        
        XCTAssertEqual(vm.alpha, 0.3)
    }
    
    func test_htmlEscaped() {
        let post = Post(type: Filter.blog, name: "", contents: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 정규 5집 선공개 Concept Teaser 2021. 01. 27. 6PM Release", date: "", thumbnail: "", title: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 정규 5집 선공개 ＜Celebrity＞ Concept Teaser", url: "")
        let vm = PostViewModel(post)
        
        XCTAssertEqual(vm.titleString, "아이유 정규 5집 선공개 ＜Celebrity＞ Concept Teaser")
        XCTAssertEqual(vm.contentString, "아이유 정규 5집 선공개 Concept Teaser 2021. 01. 27. 6PM Release")
    }
}
