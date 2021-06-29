//
//  DateUtil.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import Foundation

class ConvertUtil {
    static func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.date(from: dateString) ?? Date()
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
//        formatter.dateFormat = "YYYY년 MM월 dd일"
        formatter.dateFormat = "YYYY년 MM월 dd일 a hh시 mm분"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    /* URL로부터 Data를 얻는다. */
    static func getDataFrom(url: String) -> Data? {
        var data: Data?
        if let url = URL(string: url) {
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Failed to get data from url. error = \(error.localizedDescription)")
            }
        }
        return data
    }
}
