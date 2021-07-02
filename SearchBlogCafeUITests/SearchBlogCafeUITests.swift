//
//  SearchBlogCafeUITests.swift
//  SearchBlogCafeUITests
//
//  Created by yurim on 2021/06/28.
//

import XCTest

class SearchBlogCafeUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // 앱 실행
        app.launch()
    }
    
    override func tearDownWithError() throws {
        
    }
    
    // 검색어 입력 시 결과를 확인
    func test_searchKeyword_results() {
        search()
    }
    
    // 빈 검색어 시 결과 초기화
    func test_empty_initialize() {
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.exists)
        
        searchField.tap()           // TextField 탭
        searchField.typeText("\n")  // 빈 검색어 입력 후 키보드 내림
        
        // 3. 검색 결과가 없는지 확인 (최대 5초 동안 대기)
        let resultCellOfFirst = app.cells.firstMatch
        XCTAssertFalse(resultCellOfFirst.waitForExistence(timeout: 5))
    }
    
    // 검색 결과 중 하나를 터치 시 상세 화면으로 이동
    func test_navigate_detailView() {
        search()    // 검색
        cellTap()   // 검색 목록 중 하나 탭
    }
    
    // 포스트 링크 버튼 터치 시 URL 화면으로 이동
    func test_linkUrl() {
        search()    // 검색
        cellTap()   // 검색 목록 중 하나 탭
        
        // 링크 버튼 터치
        let linkButton = app.buttons["Link Button"]
        XCTAssertTrue(linkButton.exists)
        linkButton.tap()
        
        // URL로 이동하는지 확인
        let postVC = app.otherElements.firstMatch
        XCTAssertTrue(postVC.waitForExistence(timeout: 5.0))
    }
}

// MARK: - 중복되는 동작

extension SearchBlogCafeUITests {
    
    /* 검색 */
    private func search() {
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.exists)
        
        searchField.tap()               // TextField 탭
        searchField.typeText("아이유\n")  // 검색어 입력 후 키보드 내림
        
        // 검색 결과가 있는지 확인 (최대 5초 동안 대기)
        let resultCellOfFirst = app.cells.firstMatch
        XCTAssertTrue(resultCellOfFirst.waitForExistence(timeout: 5))
    }
    
    /* 검색 목록 중 첫 번째 셀을 터치 */
    private func cellTap() {
        let resultCellOfFirst = app.cells.firstMatch
        XCTAssertTrue(resultCellOfFirst.isHittable) // 첫 번째 셀 터치가 가능한지 확인
        resultCellOfFirst.tap()                     // 첫 번째 셀을 터치
        
        // 상세 화면으로 이동하는지 확인
        let detailVC = app.otherElements.firstMatch
        XCTAssertTrue(detailVC.waitForExistence(timeout: 5.0))
    }
}
