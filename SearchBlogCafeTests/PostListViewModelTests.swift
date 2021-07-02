//
//  SearchBlogCafeTests.swift
//  SearchBlogCafeTests
//
//  Created by yurim on 2021/06/28.
//

import XCTest

class PostListViewModelTests: XCTestCase {
    
    private var vm: PostListViewModel!
    
    override func setUpWithError() throws {
        vm = PostListViewModel()
        vm.append(posts: [Post.empty])
    }
    
    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_numberOfPosts() {
        let posts = Array(repeating: Post.empty, count: Int.random(in: 1...10))
        let numberOfPosts = vm.numberOfRows() + posts.count
        
        vm.append(posts: posts)
        
        XCTAssertEqual(vm.numberOfRows(), numberOfPosts)
    }
    
    func test_nextPage() {
        let nextPage = vm.page + 1
        
        XCTAssertEqual(vm.nextPage(), nextPage)
    }
    
    func test_getPost() {
        let count = vm.numberOfRows()
        let post = vm.post(at: count)
        
        XCTAssertNil(post)
    }
    
    func test_setRead() {
        let index = 0
        
        vm.append(posts: [Post.empty])
        vm.setDim(at: index)
        let post = vm.post(at: index)
        
        XCTAssertNotNil(post)
        XCTAssertTrue(post!.isRead)
    }
    
    func test_updateKeyword() {
        let keyword = "아이유"
        vm.updateSearch(keyword: keyword)
        
        XCTAssertEqual(vm.searchKeyword, keyword)
    }
    
    func test_postAtIndex() {
        let post = Post(type: Filter.blog,
                        name: "정란수의 브런치",
                        contents: "이 점은 \u{003c}b\u{003e}집\u{003c}/b\u{003e}을 지으면서 고민해보아야 한다. 하지만,",
                        date: "2017-05-07T18:50:07.000+09:00",
                        thumbnail: "http://search3.kakaocdn.net/argon/130x130_85_c/7r6ygzbvBDc",
                        title: "작은 \u{003c}b\u{003e}집\u{003c}/b\u{003e} \u{003c}b\u{003e}짓기\u{003c}/b\u{003e} 기본컨셉 - \u{003c}b\u{003e}집\u{003c}/b\u{003e}\u{003c}b\u{003e}짓기\u{003c}/b\u{003e} 초기구상하기",
                        url: "https://brunch.co.kr/@tourism/91")
        
        vm.append(posts: [post])
        
        XCTAssertEqual(vm.post(at: vm.numberOfRows()-1), post)
    }
    
    func test_sortedPost() {
        let posts = [Post(type: Filter.cafe,
                          name: "소울드레서 (SoulDresser)",
                          contents: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e}가 현금으로 78평 130억에 매매",
                          date: "2021-06-08T16:40:17.000+09:00",
                          thumbnail: "https://search2.kakaocdn.net/argon/130x130_85_c/57jMVZ5Qhal",
                          title: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 130억 아파트 _ 에테르노 청담",
                          url: "http://cafe.daum.net/SoulDresser/FLTB/415959"),
                     Post(type: Filter.cafe,
                          name: "IU(아이유) 공식 팬카페",
                          contents: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 정규 5집 선공개 Concept Teaser 2021. 01. 27. 6PM Release",
                          date: "2021-01-22T00:06:13.000+09:00",
                          thumbnail: "https://search3.kakaocdn.net/argon/130x130_85_c/GCEBNLVWItG",
                          title: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 정규 5집 선공개 ＜Celebrity＞ Concept Teaser",
                          url: "http://cafe.daum.net/IU/RDtR/144"),
                     Post(type: Filter.blog,
                          name: "백년노트",
                          contents: "안녕하세요. 오늘은 \u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 130억으로 유명해진 에테르노 청담에 관한 게시글을 준비했습니다.",
                          date: "2021-06-29T17:42:48.000+09:00",
                          thumbnail: "https://search1.kakaocdn.net/argon/130x130_85_c/Jl3WhfZeKxk",
                          title: "\u{003c}b\u{003e}아이유\u{003c}/b\u{003e} 130억 에테르노 청담 송중기, 어떤 곳이길래?",
                          url: "http://truetomato.tistory.com/750"),
        ]
        
        vm.updateSearch(keyword: "아이유")
        vm.append(posts: posts)
        vm.sortPosts(Sort.title)
        
        vm.sortedPosts(posts).enumerated().forEach {
            XCTAssertEqual(vm.post(at: $0), $1)
        }
    }
}
