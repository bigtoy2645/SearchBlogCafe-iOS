//
//  DateUtil.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import Foundation

class DateUtil {
    enum FormatStyle: String {
        case short = "YYYY년 MM월 dd일"
        case long = "YYYY년 MM월 dd일 a hh시 mm분"
    }
    
    /* String -> Date */
    static func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.date(from: dateString)
    }
    
    /* Date -> String */
    static func formatDate(_ date: Date, style: FormatStyle) -> String {
        let calendar = Calendar.current
        
        if style == FormatStyle.short {
            if calendar.isDateInToday(date) {
                return "오늘"
            } else if calendar.isDateInYesterday(date) {
                return "어제"
            }
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = style.rawValue
        return formatter.string(from: date)
    }
}
